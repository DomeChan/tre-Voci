# KILL (red-team) — multilang gen-1

Deduped 25 raw proposals → 14 candidates. Verdicts:

| # | Candidate | Verdict | Reason |
|---|-----------|---------|--------|
| C1 | Bundled `Languages.json` registry (decode at launch, in-code fallback) | **KEEP** | F1 linchpin; reuses catalog-load pattern; offline (P6). All 5 agents converged. |
| C2 | Kill `SongCategory` enum → category = language `code` string | **KEEP** (bundle w/ C10) | Deepest unlock — "no new enum per language" (F1). Stringly-typed risk is covered by C10's integrity gate, so they MUST ship together. |
| C3 | Home `ForEach(Language.all)` + VM `songs(for:)` | **KEEP** | Main F2 lever; kills the 3 hardcoded `.it/.zh/.en` CultureSections. |
| C4 | De-trio copy ("Three Worlds"/"3 Languages"/onboarding) → count-aware | **KEEP** | Cheap F2 win. |
| C5 | Data-drive `Song.primaryLanguage` (drop hardcoded `.it`) | **KEEP** | Removes last Italian-privilege in core model; keep no-arg computed defaulting to registry order. |
| C6 | `AppState` defaults from registry (not `["it","zh","en"]`) | **KEEP** | F2; empty-default is back-compatible with persisted JSON (dict merge-by-key). |
| C10 | Extend catalog-integrity check: authenticity-parity + orphan-code | **KEEP** | F3 falsifiability backbone; the compensating guard for C2's loss of compile-time exhaustiveness. (Allow equal lyric timestamps for refrains, not strict `<`.) |
| C8 | Honest "no recording yet" for a chosen-but-empty language | **KEEP** (light) | Sole F4 mover; only for *selected* langs, single calm treatment (avoid clutter / P-calm). |
| C11 | Locale-aware default selection in onboarding | **KEEP → EXPLORE** | Nice for "anyone", but not load-bearing for F1–F4; lower priority. |
| C12 | SpeakerStep `readyWord` + greeting from registry data | **KEEP → EXPLORE** | Real trio hardcode ("准备好了·Pronti"), but adds a registry field + width risk; gen-2. |
| C13 | Picker per-language song-count / "coming soon" | **KEEP → EXPLORE** | Overlaps C8; fold into the honesty pass later. |
| C7 | Remove named `Color.italianGreen/chineseRed/englishBlue` statics | **KILL → PARK** | High-churn, low-F-value: per-language color already comes from the registry; the statics are used as *generic palette* greens/reds in decorative spots (streak dots, research icons). Mechanical replacement risks palette shifts. Trigger: a dedicated palette-token pass. |
| C9 | Gate `availableLanguages` on non-empty `recordingSource` | **KILL → PARK** | Regression risk: tightening availability could *drop currently-playing* languages if any song lacks the (optional) credit. Conflates "has audio" with "has credit." Enforce credit at author-time via C10 instead. Trigger: after C10 confirms all songs carry `recordingSource` for every audio code. |
| C14 | Make `recordingSource` a required (non-optional) field | **PARK** | Type-tighten that fails decode app-wide if any datum missing; sequence strictly after C10 verifies full backfill. |

Killed/parked ≈ 4/14 (within the 40–60% target once EXPLORE deferrals are counted). No candidate violated a principle outright; the two KILLs are risk/sequencing, not principle conflicts.
