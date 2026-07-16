---
target: Home screen
total_score: 28
p0_count: 0
p1_count: 3
timestamp: 2026-07-15T22-22-50Z
slug: trevoci-views-home-homeview-swift
---
Method: dual-agent (A: critique-assessment-a · B: critique-assessment-b)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Live speaker route is excellent; "Play Mix" on an empty catalog silently no-ops |
| 2 | Match System / Real World | 3 | Familiar Daily Mix/play metaphors + flags; Italian-only greeting may read as odd to a non-Italian parent |
| 3 | User Control and Freedom | 3 | Player opens as `fullScreenCover`, so swipe-to-dismiss is off; recovery relies on explicit Back |
| 4 | Consistency and Standards | 3 | The system's own documented colored-glow rule is broken on song/hero-button shadows; fixed-size fonts contradict the system's own Dynamic-Type mandate |
| 5 | Error Prevention | 3 | Destructive reset is gated; empty-mix Play should be disabled, not silent |
| 6 | Recognition Rather Than Recall | 3 | Everything visible; parent-zone entry is a bare, unlabeled-looking person icon |
| 7 | Flexibility and Efficiency | 3 | One-tap Daily Mix + least-heard-first rotation is a strong efficiency win for a 20-song catalog |
| 8 | Aesthetic and Minimalist Design | 3 | Warm, well-chunked, clear hero; the uppercase "eyebrow" label is the one bit of decorative noise |
| 9 | Error Recovery | 2 | Culture sections have an honest empty state; the cross-cultural section and Daily Mix have none |
| 10 | Help and Documentation | 2 | Nothing explains "Same Song, Many Worlds" or that the mix sequences 3 languages back-to-back — the product's whole thesis is unstated on its own main screen |
| **Total** | | **28/40** | **Good (bottom edge of the 28–35 band)** |

## Anti-Patterns Verdict

**Does this look AI-generated? No — but it breaks two rules DESIGN.md itself just wrote down.**

**LLM assessment (Assessment A):** The screen passes the product-slop test overall — the truthful live speaker-route pill, time-of-day Italian greeting, per-song gradients, and two genuinely different song-card treatments (gradient tiles for cross-cultural, inset list rows for culture-specific) all read as specific and considered, not templated. Two real tells:
- **The uppercase-tracked eyebrow** on the Daily Mix hero card (`DailyMixCard.swift:42-46`, `.textCase(.uppercase).tracking(1.5)` on "🎵 Daily Mix") — DESIGN.md's own final Don't names this pattern by name as "2023-era AI scaffolding, not this system's voice." It's on the single most important surface on the screen.
- **Neutral black shadows on a system that explicitly bans them.** DESIGN.md's "Colored Glow Rule" says shadows are never neutral black — yet `SongCard.swift:64` and the Daily Mix Play button (`DailyMixCard.swift:86`) both use `.black.opacity(...)`, while the hero card's own outer glow correctly uses `.coral.opacity(0.25)`. The system knows its own rule and breaks it on the tiles.

**Deterministic scan (Assessment B):** `node .claude/skills/impeccable/scripts/detect.mjs --json TreVoci/Views/Home` → exit 0, output `[]`. Expected and not a skip: the detector reads HTML/CSS and this is a directory of `.swift` files, so it correctly found nothing in its wheelhouse. It cannot catch the two violations above — those came from Assessment A reading DESIGN.md against the actual SwiftUI modifiers.

**Visual evidence (in place of a browser overlay, which doesn't apply to native apps):** Assessment B built and ran the real app in the iOS Simulator and reached Home via a persisted-state seed (onboarding's tap-through was blocked by a simulator input-injection failure on the iPhone Air/iOS 26.2 runtime — a tooling limitation, not an app bug; see Evidence Notes below). The rendered Home screen matches the code's intent closely: genuinely warm cream background (not cold white), a coral→rose→magenta hero gradient with legible white text, and no visual glitches or misalignment in the captured region. One concrete, empirically-confirmed bug: **the Daily Mix hero card visibly reads "6 Languages" while its own accessibility label says "3 languages."** This corroborates Assessment A's independent code-level finding (below) that the visible label uses a dynamic `languageCount` while the accessibility string hardcodes "3."

## Overall Impression

This is a warm, considered screen that mostly earns its "Family Kitchen Table" brand — the Daily Mix concept, the honest empty states, and the truthful speaker pill are real strengths, not surface polish. But it's undercut by a gap between what the project's own docs demand and what the code ships: no Dynamic Type anywhere despite a font helper built and mandated for exactly this, two sub-44pt tap targets on core actions (parent-zone entry, the AirPlay picker), and — the most pointed miss — a full-brightness cream screen with no adaptation for the exact "tired parent in a dim room at bedtime" scenario PRODUCT.md names as the whole reason this product exists. The single biggest opportunity: make Bedtime Mode actually dim Home, since right now the product's stated context and its main screen's most basic visual decision contradict each other.

## What's Working

1. **The truthful speaker pill.** Reading the live `AVAudioSession` route instead of hardcoding "iPhone Speaker" (`HomeView.swift:242-300`) is a quiet, high-integrity detail — for an AirPlay-first product, "which speaker is this going to?" is the parent's real question, and answering it honestly earns trust. Also correctly Reduce-Motion-gated.
2. **The honest empty state in CultureSection** (`CultureSection.swift:23-35`): "Songs in X are on the way — we only add real native recordings." Teaches the interface's values instead of showing a dead gap, and stays fully visible (not dimmed) even for unselected languages.
3. **Daily Mix as a real one-tap accelerator**, backed by least-heard-first rotation (`HomeViewModel.swift:31-56`) — it respects the "seconds, not minutes" goal and quietly balances language exposure without asking the parent to think about it.

## Priority Issues

**[P1] No Dynamic Type anywhere on Home.** Every label uses the fixed-size `Font.nunito(_:size:)` variant (`HomeView.swift:145,149,196`; `DailyMixCard.swift:43,49,53,79`; `SongCard.swift:24,44,51`; `CultureSection.swift:31,55,76,80`) despite the codebase shipping a `relativeTo:` Dynamic-Type variant (`Font+Nunito.swift:38-40`) that both DESIGN.md and PRODUCT.md explicitly mandate for parent-facing text. A tired parent with enlarged system text gets zero scaling — 11pt durations stay 11pt. **Fix:** convert to `Font.nunito(_:size:relativeTo:)` (title→`.title`, body→`.body`, labels→`.caption`). **Suggested command:** `/impeccable typeset` or `/impeccable harden`.

**[P1] Sub-44pt tap targets on parent-zone and AirPlay controls.** The parent-zone icon button is an unbounded `Image(...).font(.system(size:28))` (`HomeView.swift:156-160`, ~28pt), and the AirPlay/speaker picker is `.frame(width:120, height:28)` (`HomeView.swift:184`) — both fail the 44×44pt minimum CLAUDE.md itself mandates. The AirPlay picker is the mechanism for the product's core "stream to the room" flow. **Fix:** `.frame(width:44,height:44)` on the parent-zone image; raise the picker's frame height to ≥44. **Suggested command:** `/impeccable adapt` or `/impeccable audit`.

**[P1] Bright, forced-light UI on a product whose defining context is a dark room.** No Dark Mode; `Color.cream` is hardcoded (`HomeView.swift:72`); the existing `bedtimeMode` flag has no effect on Home. PRODUCT.md's central use case is "a tired, one-handed parent in a dim room at bedtime" — full-brightness `#FBF8F1` is the one place the interface actively fights its own stated philosophy. **Fix:** at minimum, have `bedtimeMode` swap Home to a dark-paper palette; ideally ship a real Dark Mode appearance using semantic colors. **Suggested command:** `/impeccable colorize` or `/impeccable adapt`.

**[P2] The cross-cultural section and Daily Mix have no empty/error state.** If the catalog fails to load in a release build (the guard is DEBUG-only per `SongCatalogService.swift:11`), "🌍 Same Song, Many Worlds" sits above an empty scroll and Daily Mix shows "0 Songs · 0 Languages · ~0 min" with a Play button that silently no-ops (`HomeView.swift:234-237`). This is the one section carrying the product's actual differentiator. **Fix:** give the cross-cultural section the same honest empty-state treatment as CultureSection; `.disabled(songs.isEmpty)` on the Daily Mix Play button. **Suggested command:** `/impeccable harden`.

**[P2] VoiceOver never announces today's songs, and the language count is wrong — confirmed both in code and on-screen.** `DailyMixCard.swift:97` sets `.accessibilityElement(children:.ignore)` on the whole card, discarding the `tracklistLabel` built at line 69, and line 98 hardcodes `"…in 3 languages"` while the *visible* text uses a dynamic `languageCount` (line 52). Assessment B's simulator screenshot independently confirms the visible mismatch: the card literally reads "6 Languages" on-screen while its accessibility label says "3 languages." A screen-reader parent hears "N songs in 3 languages" — never the song names — and "3" is simply wrong once the pool is larger. **Fix:** build the label as `"Play daily mix: \(tracklistLabel), \(languageCount) languages"`. **Suggested command:** `/impeccable audit` or `/impeccable clarify`.

## Persona Red Flags

**Casey (distracted, one-handed, bottom-thumb user):**
- The primary "Play Mix" CTA sits in the hero card in the top third of the screen — outside the natural bottom thumb-arc on open.
- The 28pt AirPlay picker is a hard target for a one-handed tap; the core "send to Sonos" action is also the smallest tappable control on the screen.
- State *is* preserved across interruption (fullScreenCover + persistence) — a genuine plus for this persona.

**Sam (accessibility / screen reader / low vision):**
- Deselected culture sections dim to 0.4 opacity (`CultureSection.swift:63`) while their rows stay tappable — contrast collapses for low vision exactly where interactivity remains.
- White text over light peach/gold/rose gradients under a 0.32 black scrim (`SongCard.swift:24,44,51,60-62`) — Assessment B's screenshot confirms titles stay legible but the smaller grey-white subtitles on the lighter (tan) card are the weakest-legibility text on the screen; worth a direct contrast measurement.
- The VoiceOver tracklist/language-count issue above (P2) hits this persona directly.
- The parent-zone icon is `Color.mist` (#B8ADA0) on `Color.cream` — near-invisible visually, though it does carry a correct accessibility label.

**Project persona — "Marta, the bedtime parent"** (derived from PRODUCT.md: tired, one thumb, dim room, wants to be done in seconds):
- Opens the app in a dark room to a full-brightness cream screen — the calm promise breaks at frame one (see P1 above).
- Wants one tap and gone: Daily Mix genuinely delivers this — a real strength for her.
- Fixed 11pt durations and subtitles with no Dynamic Type mean the tired-eyes legibility PRODUCT.md explicitly asks for isn't actually there yet.

## Minor Observations

- **Italian-only greeting** (`HomeView.swift:221-224`) on a product built around tri-language *equality* — charming given the founding Italian father, but a Mandarin- or English-primary parent gets no equivalent acknowledgment. Worth a conscious decision either way.
- **Home renders the entire language registry, not just the family's selected languages.** Assessment B's accessibility-tree read found four additional "coming soon" sections (French, Spanish, German, Arabic) below the fold even though only Italian/Mandarin/English were selected in its test seed — each with a placeholder card and "on the way" copy. This roughly doubles the scroll length. This may be an intentional roadmap tease, but it wasn't visually verified and is worth a deliberate decision rather than an assumption.
- Sheet choreography uses `DispatchQueue.main.asyncAfter(0.5)` in three places (`HomeView.swift:83,98,111`) — functional, but slow relative to product-register motion guidance (150–250ms).
- No collapsing large title — the 26pt header scrolls away rather than collapsing to inline, a departure from HIG convention (acceptable given the enum-flow architecture, but worth naming).
- `greeting`'s use of `Calendar.current.component(.hour...)` is confirmed clean — not the iOS-18-only `.dayOfYear` pitfall CLAUDE.md warns about elsewhere.

## Questions to Consider

1. If the product's defining context is "a dim room at bedtime," why is the main screen's most fundamental visual decision — its background luminance — the one thing that never adapts? What would a Home that physically dims in Bedtime Mode do for a parent's trust?
2. The screen never states the product's actual thesis. A first-time parent sees "Same Song, Many Worlds" and three emoji circles but never learns the specific magic: the *same melody* sung back-to-back in three languages. Would one quiet line under that header do more for activation than any amount of visual polish?
3. The codebase ships a Dynamic Type font helper and mandates it in two design docs, then uses the fixed-size variant on every single Home label. Is that a deliberate "the layout is too tight to scale" call the docs should be updated to reflect, or an oversight the whole screen quietly inherited?

## Evidence Notes (tooling, not design findings)

- Detector (`detect.mjs`) correctly reported no findings — it's an HTML/CSS tool and doesn't apply to native SwiftUI source; this is expected, not a gap in coverage.
- Assessment B could not drive onboarding via UI-automation tap/swipe on this machine's iPhone Air/iOS 26.2 simulator (input events registered as delivered but never advanced the screen) and instead reached Home via a direct app-state seed. Onboarding itself was therefore not visually tested this run, and below-the-fold Home content (Chinese/English rows, the four placeholder language sections) is known only from the accessibility tree, not pixels.
