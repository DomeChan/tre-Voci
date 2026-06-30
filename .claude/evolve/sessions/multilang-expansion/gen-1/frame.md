# FRAME — Multi-language expansion ("anyone finds their own 'way' for their own kids")

**Target:** Generalize Tre Voci ("three voices") from a fixed IT/ZH/EN trilingual app into one where **any family configures their own set of languages** — and a new language is addable as **data, not code** — so any household can build their own multilingual "way."
**Persona:** `generic / pre-market` (primary — "any trilingual/multilingual family tomorrow") + `maker` (portability/maintenance co-validator).
**Surface:** `ios`.

## 1. Persona snapshot
- **generic/pre-market**: JTBD "show value in the first session for *any* family"; designed for translation/N-language from day one; sensitivities = high pre-trust, assuming a fixed language trio. Anti-pattern: feature-richness that assumes the it/zh/en household.
- **maker**: JTBD "add a language without a maintenance tax I'll regret"; sensitivities = abstractions hardcoded to exactly 3 languages / 1 platform; anti-pattern: a new language requiring edits scattered across view logic + a new enum case.

## 2. Surface adapter (ios — from SURFACES.md)
- Build: `xcodebuild -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone Air' build` (or MCP `build_run_sim`).
- Capture: MCP `screenshot`; bounds `snapshot_ui`. Light-only palette.
- Tokens: `Color+Theme.swift` (+ per-language hexes now live in the `Language.registry`), `Font+Nunito.swift`.
- Test runner: **none** — use the catalog-integrity Python check + runtime smoke.
- Touch target: 44pt.

## 3. Surfaces in scope (file:line)
- `Models/Language.swift:62,65` — `registryOrder` + `registry` are **hardcoded Swift statics** (it/zh/en). Adding a language = editing this file.
- `Models/Song.swift:78-80,65` — `SongCategory` enum (`italian/chinese/english/crossCultural`) is a fixed enum; `primaryLanguage` hardcodes `.it` for cross-cultural. A 4th language needs a NEW enum case → code change. **Deepest hardcoding.**
- `ViewModels/HomeViewModel.swift:10-12` — `italianSongs/chineseSongs/englishSongs` accessors.
- `Views/Home/HomeView.swift:57-83` — three hardcoded `CultureSection(.it/.zh/.en)` blocks instead of iterating `Language.all`.
- `Views/Home/HomeView.swift:215` — "🌍 Same Song, Three Worlds"; `Views/Home/DailyMixCard.swift:47` — "N Songs · 3 Languages".
- `Services/SongCatalogService.swift:37` — `italianSongs` etc. by-category helpers.
- `Views/Onboarding/LanguageStep.swift` — already iterates `Language.allCases`; "Choose at least 2 / but also 3 :)" copy is trio-flavored.

## 4. Recent context
- Commit `1dd02c1` "OPOL: generalize Language from hardcoded enum to data-driven N-language model" — did the `Language` registry refactor (good foundation, but registry still in-code).
- Just-merged `2d99797` — fixed a hardcoded `[.it,.zh,.en]` in onboarding completion → `Language.all`.

## 5. Existing constraints (CLAUDE.md / principles)
- Zero deps, **zero network, all content bundled, offline-complete** (Principle 6) — so "anyone adds a language" must stay within a *bundled* model (a config file shipped in the app), not a download. No server.
- Swift 6 `@Observable`, iOS 17, hand-managed pbxproj, light-only.
- Nunito is **Latin-only** — a non-Latin new language (Arabic, Hindi, etc.) needs script-aware font handling + possibly RTL.

## 6. Principles served
- **3 (trilingual→multilingual exposure)** — the core: more genuine multilingual reach for more families.
- **maker `portability`** — a new language is data, reusable for the planned Flutter port.
- **10 (honest about limitations)** — if a chosen language lacks content for a song, say so.

## 7. Principles at risk
- **4 (cultural authenticity)** — each new language needs a *real* native recording + correct lyrics, not machine filler. Generalizing the plumbing must NOT invite fake/placeholder languages.
- **6 (offline/bundled)** — must not drift toward downloadable language packs / network.
- **2 (sync integrity)** — per-language lyric timing must hold for new languages.
- **11/typography** — non-Latin scripts (RTL, CJK beyond zh) stress the Latin-only Nunito + layouts.

## 8. Best-in-class reference (evidence, not authority)
- **Gus on the Go / PandaTree / Duolingo ABC** — pick-your-language kid apps: language is a first-class data entity; the UI is one templated screen iterated per chosen language, not N bespoke screens. What would make them wrong here: they're online/account-based and engagement-looped — we stay offline/calm.
- **Yoto** — content-as-data cards; adding content never ships a new screen. Good model for "language = data."

## 9. Fitness signal (falsifiable)
- **F1 (data-not-code):** adding a language is editing a **bundled `Languages.json`** registry + catalog content keyed by that code — **zero** view-logic edits, **no new enum case**. Smoke: seed a 4th language entry (e.g. `es`) and watch it flow onboarding→home→exposure with no code change. *(Ties to G3-style data-truth + runtime smoke.)*
- **F2 (no residual hardcoding):** no `.it/.zh/.en` literals or "3 Languages"/"Three Worlds" in **view logic** (preview-only convenience accessors OK); Home iterates `Language.all`.
- **F3:** build green + catalog-integrity Python check passes.
- **F4 (honest):** a chosen language with no content for a song is shown as unavailable, not silently dropped (Principle 10).

## 10. Out of scope (this gen)
- Actually authoring new-language audio/lyric content (Principle 4 — needs real recordings; that's a content effort, not this gen).
- RTL layout + non-Latin font pipeline (PARK candidate — flag, don't build blind).
- Flutter port. Donation/StoreKit. Any network/download mechanism (violates Principle 6).
