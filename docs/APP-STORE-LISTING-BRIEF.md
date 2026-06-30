# App Store listing screenshots — Tre Voci brief

> Tre-Voci adaptation of the `app-store-launch` skill (which wraps **ParthJadhav/app-store-screenshots**).
> The skill's stock prompt is GuardianAI/Habib-specific — this is the Tre Voci version.
>
> **Two different deliverables — don't conflate:**
> 1. **Listing screenshots** (this doc) — the marketing images on the App Store product page.
> 2. **IAP review screenshot** — a plain donation-screen capture for the tip products → `scripts/asc_upload_iap_screenshot.py`. Separate, simpler.

## Install (one-time, gated — you run it)
```bash
npx skills add ParthJadhav/app-store-screenshots -g    # downloads third-party code; approve the prompt
node --version   # need ≥18 (have v20)
```

## Source frames (capture from the app first)
The tool marks up real app screenshots as ads. Capture these clean (an Xcode run loads everything, incl. the StoreKit tiers):
- **Home** — "Same Song, Many Worlds" + the trilingual library (hero: the magic).
- **Player** — synced lyrics + language pills + AirPlay (hero: same melody, three voices).
- **Parent Zone → exposure** — the weekly per-language rings (hero: honest, real stats).
- **Onboarding → language pick** — flag chips (hero: choose your family's languages).
- *(optional)* **Donation** — the tip-jar (doubles as the IAP review screenshot).

## The prompt to paste (after install)
```
I'm producing App Store listing screenshots for **Tre Voci**, using the ParthJadhav/app-store-screenshots skill I've installed.

CONTEXT:
- App: Tre Voci — an audio-first, trilingual (and now multilingual) nursery-rhyme app for toddlers. The same song in multiple languages; bundled, offline, zero ads/tracking/accounts; streams to HomePod/Sonos via AirPlay.
- Brand/voice: warm, calm, parent-trustworthy, indie/handmade. Palette: cream #FBF8F1, warm #F5F0E6, ink #3A3028, coral #FF7B6B accent (see Color+Theme.swift). Font: Nunito.
- Category (Apple): primary **Education**, secondary **Music**. Audience: **Kids 0–5 / Made for Kids**.
- No partner, no PII. Use the in-app demo child name ("Olivia") only.

THREE HERO CLAIMS (priority order):
1. "One song, many voices" — the same nursery rhyme, sung in each of the family's languages. The core delight.
2. "No ads. No tracking. No accounts. Nothing leaves your iPhone." — parent trust; rare and load-bearing for a kids app.
3. "Built by one dad for his trilingual toddler." — indie authenticity (also the tip-jar story).
ADDITIONAL (if >3 frames): "Audio-first — works with the screen off, casts to your HomePod" · "Honest exposure stats, no vanity metrics" (Parent Zone).

SOURCE SCREENS (capture provided in ./app-store-assets/source/):
- home — hero: trilingual library, "Same Song, Many Worlds"
- player — hero: synced lyrics, the language pills (it/zh/en/…)
- parent-exposure — hero: weekly per-language minutes
- onboarding-language — hero: "choose your family's languages" flag chips

DEVICE SIZES TO EXPORT (Apple current):
- iPhone 6.9" (Pro Max) — required
- iPhone 6.7" — required
- iPad 13" — required (universal app, iPad-supported)

LOCALES:
- en-US first (this run).
- it-IT and zh-Hans next run (the app is genuinely trilingual — localized listings are on-brand). Queue, don't block.

CONSTRAINTS:
- Warm/calm aesthetic — NOT loud/gamified. This is a bedtime-adjacent kids app.
- No competitor framing, no comparison (Apple rejects).
- Kids-app safe: no PII, no external links in the frames.
- Lead with the trilingual hook + the privacy promise; those are the two things no competitor pairs.

OUTPUT:
- Save to ./app-store-assets/2026-XX-XX-launch/<locale>/<device>/<frame>.png
- Emit a manifest JSON (size, locale, device, source frame).

REVIEW LOOP:
1. Draft V1: en-US + iPhone 6.9" only (smallest viable set).
2. I review, request changes; regenerate only changed frames.
3. Approve → expand to all device sizes in en-US.
4. Then it-IT / zh-Hans is a later run.
Begin with step 1.
```

## After the run
- Save the manifest; the PNGs upload to App Store Connect → the app version → Screenshots (manual, per device size). The tool ends at PNG export — it does not submit.
- This kit + brief becomes the reusable Tre Voci store-asset template.
