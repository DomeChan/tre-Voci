# REPORT — multilang-expansion gen-2

Seeded by gen-1 lessons (memory `multilang-expansion-evolve`). Focused EXPLORE pass — candidates were pre-specced in gen-1 IDEATE, so no new fan-out. Branch `evolve/multilang-expansion`. Build green, integrity green.

## Shipped (EXPLORE → done)
- **C11 — locale-aware onboarding default.** `OnboardingContainer.defaultSelection()` preselects the device-locale language (if registered) + English, topped up to the 2-language floor from registry order. No hardcoded trio; works for any locale. (Was `Set(Language.all)`.)
- **C12 — registry `readyWord`.** New `readyWord` field in `Languages.json`/`LanguageDef`; the SpeakerStep finish button is built from the family's chosen languages' ready-words (`Pronti! · 准备好了!` now data-derived, capped at 3 for width) instead of the hardcoded IT/ZH literal.
- **C13 — picker content honesty.** `LanguageStep` shows a per-language song count ("12 songs") or "coming soon", and **disables** selection of a zero-content registered language — so a family can't pick a promise the bundle can't keep (P10).

## Red-team call (this gen)
- **C9 (gate `availableLanguages` on `recordingSource`) — kept PARKED.** Gen-1's catalog-integrity check already hard-fails on any audio-without-credit at author time — the correct layer for the invariant. A runtime gate would be redundant and couple availability to credit data. Enforcement stands; the runtime gate adds nothing.

## Verification
- Build green (0 warnings); `scripts/catalog_integrity.py` passes (20 songs, 3 languages, 2 pre-existing pinyin warnings).
- Onboarding's internal steps were build- + logic-verified, not runtime-navigated (no reliable tap/scroll tooling + state-reset in this env — documented limit). The greeting stayed Italian (brand identity, "Tre Voci") by choice — parked as a separate decision, not a bug.

## Remaining (gen-3 / park)
- Italian greeting → neutral/per-language (deferred — brand-identity call for the user).
- PARK unchanged: drop named Color statics, required `recordingSource`, RTL/non-Latin font pipeline.
