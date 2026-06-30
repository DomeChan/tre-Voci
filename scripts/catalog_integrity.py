#!/usr/bin/env python3
"""Catalog + language-registry integrity check — Tre Voci's de-facto test runner.

There is no XCTest target (see SURFACES.md); this is the regression gate. It
enforces the N-language data contract so a malformed or half-authored language
fails LOUDLY at author time instead of shipping silence.

Run: python3 scripts/catalog_integrity.py
Exit 0 = pass. Non-zero = fail (prints every violation). Warnings don't fail.
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, "TreVoci", "Resources")
AUDIO = os.path.join(RES, "Audio")

errors: list[str] = []
warnings: list[str] = []


def load(name):
    with open(os.path.join(RES, name), encoding="utf-8") as f:
        return json.load(f)


langs = load("Languages.json")
catalog = load("SongCatalog.json")

registry = langs.get("languages", {})
order = langs.get("order", [])
registered = set(registry.keys())

# --- registry self-consistency ---
for code in order:
    if code not in registry:
        errors.append(f"Languages.json: order lists '{code}' but it has no entry")
for code, d in registry.items():
    if code not in order:
        warnings.append(f"Languages.json: '{code}' defined but missing from order")
    for field in ("displayName", "flag", "primaryHex", "backgroundHex", "familyRole", "familyIcon"):
        if not d.get(field):
            errors.append(f"Languages.json[{code}]: missing/empty '{field}'")

songs = catalog.get("songs", [])
langs_with_content = set()

for s in songs:
    sid = s.get("id", "<no-id>")
    cat = s.get("category")
    audio = s.get("audioFiles", {})
    titles = s.get("titles", {})
    lyrics = s.get("lyrics", {})
    sources = s.get("recordingSource", {}) or {}
    duration = s.get("duration", 0)

    # category is "cross-cultural" or a registered language code
    if cat != "cross-cultural" and cat not in registered:
        errors.append(f"{sid}: category '{cat}' is neither 'cross-cultural' nor a registered language")

    # every code appearing anywhere must be registered (orphan-code guard)
    seen_codes = set(audio) | set(titles) | set(lyrics) | set(sources)
    for code in seen_codes:
        if code not in registered:
            errors.append(f"{sid}: uses unregistered language code '{code}' (add it to Languages.json)")

    # per-(song, audio-language) authenticity parity
    for code, path in audio.items():
        langs_with_content.add(code)
        fpath = os.path.join(AUDIO, path)
        if not os.path.exists(fpath):
            errors.append(f"{sid}/{code}: audio file missing on disk: {path}")
        if not titles.get(code):
            errors.append(f"{sid}/{code}: has audio but no title")
        if not sources.get(code):
            errors.append(f"{sid}/{code}: has audio but no recordingSource (no anonymous recordings)")
        lines = lyrics.get(code, [])
        if not lines:
            errors.append(f"{sid}/{code}: has audio but no lyrics (pretend-synced caption guard)")
        else:
            times = [ln.get("time", 0) for ln in lines]
            # non-decreasing (equal allowed for repeated refrains at the same stamp)
            if any(b < a for a, b in zip(times, times[1:])):
                errors.append(f"{sid}/{code}: lyric timestamps not non-decreasing: {times}")
            if duration and times and times[-1] > duration + 0.5:
                errors.append(f"{sid}/{code}: last lyric time {times[-1]} exceeds duration {duration}")
            # romanization for non-latin (isRomanizable) languages — a WARNING, not
            # a hard fail: missing pinyin degrades the parent guide gracefully (shows
            # the script without it) rather than lying, and it must be filled with
            # VERIFIED romanization (never fabricated — wrong tones = inauthentic, P4).
            if registry.get(code, {}).get("isRomanizable"):
                missing = [i for i, ln in enumerate(lines) if not ln.get("romanization")]
                if missing:
                    warnings.append(f"{sid}/{code}: isRomanizable but {len(missing)} lyric line(s) lack romanization (add verified pinyin)")

# a registered language with zero bundled content is allowed (shown "coming soon"),
# but worth flagging so the maker knows it's promised-but-empty.
for code in registered:
    if code not in langs_with_content:
        warnings.append(f"language '{code}' is registered but has no song content yet (will show as 'coming soon')")

for w in warnings:
    print(f"  warning: {w}")
if errors:
    print(f"\nFAIL — {len(errors)} integrity violation(s):")
    for e in errors:
        print(f"  ✗ {e}")
    sys.exit(1)
print(f"\nOK — {len(songs)} songs, {len(registered)} registered languages, integrity passed"
      + (f" ({len(warnings)} warning(s))" if warnings else ""))
