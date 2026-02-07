# Tre Voci — Three Voices, One Song

An experimental iOS app designed to support trilingual language development in young children through audio-first nursery rhymes and songs.

## Purpose

Tre Voci is built around a simple premise: **children learn languages through exposure and repetition**, but the mechanics of modern apps often work against healthy development. This project explores how to create a tool that:

- 🎵 **Plays nursery rhymes** in Italian, Mandarin Chinese, and English
- 🎧 **Prioritizes audio** as the primary interface (reducing screen time and visual dependency)
- 🎯 **Streams to speakers** via AirPlay 2, enabling shared family listening experiences
- 📊 **Tracks exposure** to each language without behavioral addiction mechanics
- 🛡️ **Removes harm vectors** — no analytics, no tracking, no engagement optimization, no notifications

The app is designed for bilingual/multilingual households where parents want their children to develop equal fluency across languages without relying on screens.

## Experimental Phase

This project is **intentionally experimental**. We are actively exploring:

**How do we measure child language outcomes without surveillance?**
- Current approach: minimal session tracking (duration, languages heard)
- No child profiling, behavioral analytics, or personalization metrics
- Manual parent review via the "Parent Zone" — intentionally low-tech

**How do we avoid addictive design patterns?**
- No push notifications or streak mechanics
- No social features or competitive elements
- No algorithmic content recommendations
- Simple, predictable UX that doesn't encourage excessive use
- All decisions remain with the parent/caregiver

**What does healthy audio-first interaction look like for young children?**
- Testing AirPlay-to-speaker workflow vs. direct device audio
- Exploring whether song selection feels natural and not gamified
- Observing how families integrate music into daily routines

We are **documenting our learnings** in this repository and welcome research collaboration.

## Open Source

Tre Voci is open source under the [MIT License](./LICENSE). You are free to:
- Fork and adapt for your family's language mix
- Contribute improvements (especially around pedagogical content and UX)
- Use the codebase as reference for your own family audio app
- Research how app design impacts child behavior

We ask that you:
- Do not add engagement optimization or dark patterns
- Do not add tracking or analytics
- Do not add in-app purchases or ads
- Credit the original authors if you redistribute

## Technical Stack

- **iOS 17+** (SwiftUI, no third-party dependencies)
- **All content bundled** (no network calls, no cloud sync)
- **Local state only** (UserDefaults persistence)
- **AirPlay 2 support** for speaker routing

See [CLAUDE.md](./CLAUDE.md) for the complete build specification and [docs/TRE-VOCI-PRD.md](./docs/TRE-VOCI-PRD.md) for the design rationale.

## Getting Started

1. Clone this repository
2. Open `TreVoci.xcodeproj` in Xcode 16+
3. Build for iOS 17.0+ simulator
4. Add your own nursery rhyme audio files (see Phase 2 in CLAUDE.md)

## Current Status

✅ **MVP Complete** (as of February 2026)
- Full UI/UX implemented
- 36 real audio files (Italian, Mandarin, English nursery rhymes)
- Onboarding, home screen, player, activity tracking, parent zone
- AirPlay 2 integration
- Session logging and exposure charts

🧪 **Now in family testing** — we are using this daily with a 2-year-old in a trilingual household (Italian father, Mandarin mother, English school) to understand what works and what doesn't.

## Contributing

We welcome:
- Pedagogical feedback (song selection, pacing, activity prompts)
- Design critiques (especially around avoiding addictive patterns)
- UX testing (how real families use the app)
- Translation of content into other languages
- Bug reports and accessibility improvements

Please open an issue to discuss before submitting PRs. This is an experimental project, so we prioritize alignment on philosophy over feature velocity.

## License

MIT License. See [LICENSE](./LICENSE) for details.

---

**Project created by domechan**
*Exploring how technology can support early language development without causing harm.*

If you're a parent, researcher, or educator interested in this problem space, we'd love to hear from you.
