# Value framework — Tre Voci

> Adapted for **Tre Voci**: an audio-first trilingual (Italian / Mandarin Chinese / English) nursery-rhyme
> iOS app for a 2-year-old in a trilingual household. Streams to HomePod/Sonos via AirPlay 2. Zero
> dependencies, zero network, zero tracking — all content bundled. The orchestrator reads THIS file.

Three layers: **Principles** (immutable spine), **Personas** (pick one per run), **Lenses** (questions ideators ask).
References (Super Simple Songs, BabyBus 宝宝巴士, Coccole Sonore, Apple Music/Podcasts player UX) are
**evidence, not authority** — always judged against the principles below.

---

## 1. Principles — what Tre Voci is for

| # | Principle | One-line test |
|---|-----------|---------------|
| 1 | **Audio-first** | Does this add value with the screen off / the child not looking? Core interaction that *requires* watching the screen = KILL. |
| 2 | **Sync integrity** | Do the captions match what's actually sung (≤~1s), looped across every verse repeat, with smooth IT→ZH→EN transitions? Drift, dead-air intros, or wrong-language captions = KILL. |
| 3 | **Trilingual exposure** | Does this increase or clarify genuine multilingual exposure, or dilute it? Every cross-cultural song should deliver all chosen languages continuously. |
| 4 | **Cultural authenticity** | Is the content a real song with correct lyrics and native pronunciation in each language — not machine-translated filler or the wrong recording? |
| 5 | **Calm, not addictive** | Does this respect a finite, calm session (just-in-time), or add engagement loops / endless autoplay / dark patterns? Always-on = KILL. |
| 6 | **Zero tracking / offline-complete** | Any network call, analytics, tracking, or data egress = KILL. Must work in airplane mode on first launch; all content bundled. |
| 7 | **Parent trust & control** | Does it keep the parent in control (parent gate, owns settings) and honestly informed (real exposure stats, no vanity metrics, no creepy tracking)? |
| 8 | **Toddler-operable** | Can a 2-year-old's imprecise tap (or a parent one-handed) succeed? No reading required of the child; forgiving, large targets. |
| 9 | **Accessibility** | Every interactive element has an `accessibilityLabel`, meets 44×44pt, respects Dynamic Type (where text exists) and reduce-motion. |
| 10 | **Honest about limitations** | If audio is missing/placeholder or a language isn't available, the UI says so. No fake content, no pretend-synced captions. |
| 11 | **Calm visual craft** | Soft palette, rounded forms, gentle spring animations — consistent with the established design tokens (§ SURFACES). No jarring motion or loud sudden audio. |
| 12 | **AirPlay-first listening** | Does this stay correct when streaming to a HomePod/Sonos (lock-screen Now Playing, remote commands, no screen needed)? |

When IDEATE produces a candidate it must declare which principles it serves. KILL rejects candidates that
serve none and flags candidates that *trade* one principle for another (e.g. engagement vs. calm) for explicit resolution.

---

## 2. Personas — who we build for

### Persona `toddler` — the listener (Mei, 2, trilingual household)
- **Context / environment**: held by a parent, in a car seat, or at home at bedtime; often **not looking at the screen**; cannot read; audio frequently on a HomePod/Sonos across the room.
- **Relationship**: trusts the *sounds*; delighted by repetition, animals, and clapping/action songs; soothed by familiar melodies.
- **Language / locale**: hears Italian, Mandarin, and English interchangeably; no reading.
- **Top jobs-to-be-done**:
  1. "Play the song I love — again, and again."
  2. "Make the fun animal sound / let me clap and dance along."
  3. "Sing the same tune in my three languages."
- **Sensitivities**: startling/loud sudden audio, abrupt stops, overstimulation, tiny controls, long silences before the singing starts.
- **Anti-patterns** (→ KILL criteria): reading-required UI, ads, jarring transitions, endless autoplay / engagement loops, screen-gated core interaction, captions out of sync with the singing.

### Persona `parent` — the operator & guardian (Domenico, trilingual dad, the buyer)
- **Context / environment**: iPhone, frequently **one-handed** while multitasking (cooking, bedtime); wants to AirPlay to HomePod/Sonos in seconds.
- **Relationship**: cares about the child's language development and feels screen-time guilt; wants *evidence of exposure* without surveillance; is the trust anchor for what the child consumes.
- **Language / locale**: fluent IT/ZH/EN; values authentic, correct content and will notice a wrong recording or mistranslation immediately.
- **Top jobs-to-be-done**:
  1. "Start a calm trilingual session fast, eyes-free, and cast it to the speaker."
  2. "See honestly how much of each language she's heard this week."
  3. "Trust there's no tracking, no ads, no hidden cost — and set which languages we're using."
- **Sensitivities**: privacy/tracking, ads, inauthentic content, screen-time, hidden costs, English-default UI in a non-English home.
- **Anti-patterns**: any data collection, engagement-maximizing dark patterns, vanity stats, anything needing constant attention, content that doesn't match its label.

### Persona `generic / pre-market` (keep)
- **Context**: a toddler-content app for "no specific family today, any trilingual family tomorrow."
- **Language**: designed for translation from day one (no concatenated strings; per-language content keyed, not hardcoded).
- **JTBD**: "Show value in the first session"; "don't ask for permissions before value"; "make exposure legible without tracking."
- **Sensitivities**: high — pre-trust. **Anti-patterns**: feature-richness without journey clarity; assuming brand recognition.

### Persona `maker` — the indie developer & maintainer (us, solo/tiny team shipping Tre Voci)
- **Context / environment**: one developer, hand-managed Xcode project (`pbxproj` edited by hand), no CI test target, no paid backend, no analytics to lean on. Every line is something *we* will maintain at 11pm after the kid is asleep. Build-and-ship cycles are measured against a single person's hours.
- **Relationship**: we are the trust anchor *and* the cost center. The app must be **sustainable to keep alive** (a tip jar can fund the Apple Developer Program fee and audio re-mastering) without ever betraying the parent's privacy or the toddler's calm. We win when a change is small, obvious, reversible, and pays rent in maintainability or sustainability.
- **Constraints / locale**: Apple frameworks only (zero third-party deps), Swift 6 + `@Observable`, iOS 17 floor, light-only palette, hand-managed pbxproj. Cross-platform Flutter migration is *planned*, so abstractions should be portable, not Swift-locked.
- **Top jobs-to-be-done**:
  1. "Ship a polished change without adding a dependency, a tracking call, or a maintenance tax I'll regret."
  2. "Earn enough goodwill/funding to keep the app alive (optional, parent-gated tip jar via StoreKit) — never via ads, data, or dark patterns."
  3. "Keep the codebase small, legible, and portable so the next feature (or the Flutter port) is cheap."
- **Sensitivities**: dependency creep, hidden maintenance cost, anything that needs a server or breaks offline-complete, pbxproj corruption, abstractions hardcoded to exactly 3 languages / 1 platform, features that look good in a demo but rot.
- **Anti-patterns** (→ KILL criteria): adding an SPM/CocoaPod, any network/analytics/tracking, ads, monetization that pressures or deceives the parent, one-off code that duplicates an existing token/service, "clever" code a solo maintainer can't safely change later, monetization not behind the parent gate.
- **Sustainability note**: the only acceptable revenue is an **optional, parent-gated, no-pressure Apple StoreKit tip jar** ("support the maker") — no third-party SDK, no network call by us, no tracking, fully functional offline-after-purchase. It must serve Principle 7 (parent trust) and never violate Principle 5 (calm) or 6 (zero tracking). If a monetization idea can't clear all three, it's KILLed.

---

## 3. Lenses — the questions ideators ask

Use 3–6 per invocation, ≥1 value lens and ≥1 reference lens.

### Value lenses (always ≥1) — generic + Tre Voci domain
| Lens | Question |
|------|----------|
| `jobs-to-be-done` | What is the user (toddler or parent) trying to do *in this exact moment*? What lets them succeed faster, calmer? |
| `audio-first` | Does this work with the screen off / child not looking / audio on a remote speaker? Eyes-free first. |
| `sync-integrity` | Do audio, captions, and IT→ZH→EN transitions stay aligned and looped? (The thing we just re-mastered — protect it.) |
| `trilingual-continuity` | Across the three language segments, does the song feel like *one continuous experience*, not three clips? |
| `calm-not-addictive` | Does this respect a finite, calm session — no engagement loops, no endless autoplay, no nagging? |
| `toddler-motor` | Can a 2-year-old's imprecise tap succeed? Targets ≥44pt, forgiving, no precision required. |
| `proof-of-life` | Does the parent see honest evidence it's working (real exposure stats, session receipts) — never vanity metrics? |
| `time-to-first-value` | Can a brand-new family hear a real trilingual song within the first session, before any setup friction? |

### Market / per-language lenses (use when content/locale is in scope)
| Lens | Question |
|------|----------|
| `cultural-fit-it` | Authentic Italian (real song, correct lyrics, native singing, IT copy) — not a translated stand-in? |
| `cultural-fit-zh` | Authentic Mandarin (correct characters incl. tone-faithful lyrics, native singing, no embedded ads/【订阅】 prompts)? |
| `cultural-fit-en` | Authentic English nursery rhyme (the right version) — no spoken-skit substitutes? |
| `cross-language-portability` | If we add a 4th language tomorrow, is the abstraction reusable, or did we hardcode 3? |

### Reference lenses (always ≥1)
| Lens | Question |
|------|----------|
| `best-in-class-reference` | What does the best we've seen do here? Content refs: Super Simple Songs (EN), BabyBus 宝宝巴士 (ZH), Coccole Sonore (IT). UX refs: Apple Music / Podcasts now-playing & lock-screen, Yoto/Tonies for audio-first kids. **Evidence, not authority** — cite file/screen/URL. |
| `inverse-best-in-class` | What's the trap? (e.g. YouTube-kids autoplay rabbit-holes, ad-stuffed nursery channels, karaoke apps whose captions drift.) |

### Engineering lenses (reuse as-is)
`technical-risk`, `performance`, `test-coverage`, `simplicity`, `a11y`, `design-system`, plus Tre Voci specifics:
`swift6-concurrency` (`@Observable`/`@MainActor`, no Combine), `ios17-api` (avoid iOS-18-only APIs), `zero-dependency` (Apple frameworks only — any SPM/CocoaPod = KILL), `pbxproj-hygiene` (hand-managed project file).

### Maker / indie-dev lenses (use ≥1 when framing for persona `maker`)
| Lens | Question |
|------|----------|
| `maintenance-tax` | Will a solo developer be able to safely change this in six months? Does it duplicate an existing token/service, or reuse one? Smaller + obvious wins. |
| `ship-velocity` | Does this ship without adding a dependency, a server, or a test-infra burden we don't have? Can it be built + gated in one sitting? |
| `sustainability` | Does this help keep the app *alive* (fund the dev-program fee / audio re-mastering) **only** via an optional, parent-gated, no-pressure StoreKit tip jar — never ads, data, or dark patterns? |
| `portability` | Is the abstraction reusable for the planned Flutter port and for an Nth language, or hardcoded to Swift / exactly 3 languages? (pairs with `cross-language-portability`) |
| `reversibility` | If this is wrong, how cheaply can we back it out? Prefer additive, token-routed, single-file changes over cross-cutting rewrites. |

> The net-new **`donation`** surface (SURFACES.md) is owned primarily by persona `maker` (lens `sustainability`) but MUST be co-validated by persona `parent` (Principle 7 trust, Principle 6 zero-tracking, Principle 5 calm): optional, parent-gated, StoreKit-only, no pressure, works offline.

> Note: `dark-mode` is currently **out of scope** — Tre Voci ships a single warm light palette by design. A `dark-mode` candidate must first argue it serves Principle 11, or it's parked.

---

## How FRAME uses this
The FRAME brief MUST declare: Target, Persona (§2 key or "none"), Surface (SURFACES.md key), Principles served
(1–3 from §1), Principles at risk, Lenses (3–6 incl. ≥1 value + ≥1 reference), Reference (file:line/URL).
KILL rejects ideas mapping to no principle; VALIDATE confirms the merged work serves them.

This framework is **add-only**: principles immutable, personas extend, lenses extend.
