# ALLOCATE — multilang gen-1

**Note on parallelism:** This is a cross-cutting core-model refactor (Language.swift, Song.swift, SongCatalogService, AppState, HomeView all interlock). Per skill "When NOT to use … cross-cutting refactors — run sequentially." So EXPLOIT is implemented by the orchestrator **inline + sequential**, building/gating between coherent groups — NOT parallel worktree executors that would collide on the same files.

## EXPLOIT — implement this generation (the F1/F2/F3 core)
Order respects dependencies:
1. **C1** — `Languages.json` bundled registry (+ pbxproj resource entry). *Group: registry.*
2. **C2** — kill `SongCategory` → `category: String` == language code; migrate the 12 culture-specific catalog `category` values to codes. *Group: model.*
3. **C5** — data-drive `Song.primaryLanguage` (registry order, never `.it`). *Group: model.*
4. **C6** — `AppState` registry-driven defaults / tolerant dicts. *Group: model.*
5. **C3** — Home `ForEach(Language.all)` + `HomeViewModel.songs(for:)`; drop by-name catalog accessors. *Group: home.*
6. **C4** — de-trio copy (count-aware). *Group: home/onboarding.*
7. **C10** — extend the catalog-integrity Python check (authenticity-parity + orphan-code). *Group: gate.* MUST land with C2.
8. **C8** — light honest "no recording yet" for a selected-but-empty language. *Group: honesty.*

**Fitness demonstration (the gen's proof):** after EXPLOIT, seed a 4th language `es` in `Languages.json` + one culture-specific catalog song with `"category":"es"` → it must flow onboarding→Home→exposure with **zero Swift edits** (F1), build green + integrity passes (F3), and grep shows no `.it/.zh/.en`/"Three Worlds"/"3 Languages" in view logic (F2). Then REMOVE the `es` smoke data before merge (no half-language ships — P4).

## EXPLORE — gen-2 candidates
- **C11** locale-aware onboarding default selection.
- **C12** registry `readyWord` for SpeakerStep finish + neutral greeting.
- **C13** picker per-language content count / "coming soon".

## PARK — with re-evaluation triggers (→ memory)
- **C7** drop named language Color statics → **trigger:** a dedicated palette-token pass, or a new language whose color clashes.
- **C9** gate availability on `recordingSource` → **trigger:** after C10 confirms every song has `recordingSource` for all its audio codes (then it's a safe tightening, not a regression).
- **C14** make `recordingSource` required → **trigger:** C9 landed + full backfill verified.
- **RTL / non-Latin font pipeline** (frame §10) → **trigger:** first non-Latin language scheduled (Nunito is Latin-only; needs script-aware font + RTL).
