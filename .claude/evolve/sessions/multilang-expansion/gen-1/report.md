# REPORT — multilang-expansion gen-1

**Target:** expand beyond fixed IT/ZH/EN so any family configures its own languages and a new language is **data, not code**. **Branch:** `evolve/multilang-expansion`. **Merge:** manual (not merged).

## Fitness — all met
- **F1 (data-not-code):** seeded `es` in `Languages.json` only → built green + flowed to Home with **zero Swift edits, no new enum case**. (Smoke data then removed — no half-language ships, P4.)
- **F2 (no residual hardcoding):** Home renders `ForEach(Language.all)`; grep shows no `.it/.zh/.en`/"Three Worlds"/"3 Languages" in view/VM logic — only the documented fallback registry + comments.
- **F3:** build green (0 warnings) + `scripts/catalog_integrity.py` passes (20 songs, 3 languages).
- **F4:** chosen-but-empty language shows an honest "Songs in X are on the way — we only add real native recordings" state, not a silent gap.

## Merged into the gen (EXPLOIT)
- **C1** `Languages.json` bundled registry (decode at launch + in-code fallback); `LanguageDef: Codable`; pbxproj resource wired.
- **C2** killed `SongCategory` enum → `Song.category: String` == language code; migrated 12 catalog category values to codes; `songsByLanguage` buckets by code.
- **C5** `Song.primaryLanguage` data-driven (registry order, never `.it`) + `primaryLanguage(preferring:)`.
- **C6** `AppState` registry-driven (empty) defaults; weekly-reset no longer hardcodes the trio.
- **C3** Home `ForEach(Language.all)` + `HomeViewModel.songs(for:)`; dropped `italian/chinese/englishSongs`; data-driven `sectionTitle` (charming titles preserved as data, fall back to flag+name).
- **C4** de-trio copy: "Many Worlds"; Daily Mix language count derived from data.
- **C10** extended catalog-integrity check: orphan-code guard, audio↔title↔lyrics↔recordingSource parity, non-decreasing lyric timestamps, romanization (warning).
- **C8** honest empty-state for chosen-but-empty languages.
- Loud DEBUG assertion for an unregistered code (graceful globe only in production).

## Findings surfaced (real, pre-existing)
- `happy-birthday/zh` and `abc-song/zh` have Chinese lyrics with **no pinyin romanization** → integrity warnings. NOT fabricated (wrong tones = inauthentic, P4); flagged for the maker to fill with verified pinyin.

## Deferred (see allocation.md + memory)
- EXPLORE gen-2: locale-aware onboarding default (C11), registry `readyWord` for SpeakerStep + greeting (C12), picker per-language content count (C13).
- PARK: drop named `Color` language statics (C7), gate availability on `recordingSource` (C9 — now safe to revisit since all 20 songs carry it), required `recordingSource` (C14), RTL/non-Latin font pipeline (Nunito is Latin-only).

## Lessons
- The OPOL "registry" was data-*shaped* but code-*resident*; true data-not-code needed the bundle file + killing the category enum. The enum was the real blocker.
- A stringly-typed category is only safe with the integrity check shipped alongside — they're one change.
- Nunito is Latin-only: per-glyph fallback covers mixed labels, but a non-Latin language is a real PARK (font + RTL), not a data edit.
