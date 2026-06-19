# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is Tre Voci?

Audio-first trilingual nursery rhyme app for iOS. Plays songs in Italian, Mandarin Chinese, and English. Designed for a 2-year-old in a trilingual household. Streams to Sonos/HomePod via AirPlay 2. No third-party dependencies, no network calls, no tracking. All content bundled in the app.

Full PRD: `docs/TRE-VOCI-PRD.md` | Audio pipeline: `docs/AUDIO-SOURCING-GUIDE.md`

## Build Commands

```bash
# Build (use iPhone Air — no iPhone 16 simulator available)
xcodebuild -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone Air' build

# Run tests
xcodebuild test -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone Air'

# Run specific test class
xcodebuild test -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone Air' -only-testing:TreVociTests/AudioFileExistenceTests
```

Note: An `appintentsmetadataprocessor` warning appears in builds — this is system-level noise, not a real issue.

## Constraints

- **Zero dependencies** — Apple frameworks only (no SPM, no CocoaPods)
- **Swift 6, SwiftUI, iOS 17+** deployment target
- **MVVM with `@Observable`** — never use `ObservableObject`
- **No network calls, no analytics, no tracking** — local state only via UserDefaults
- **Portrait only**, no iPad-specific layouts

## Architecture

### App Entry & Navigation
`TreVociApp.swift` → creates `PersistenceService` as `@State`, passes it via `.environment()`. `ContentView` uses enum-based `FlowState` (splash/onboarding/home) — not NavigationStack at the root level.

### Data Flow
- **`PersistenceService`** (`@Observable`) — wraps UserDefaults, encodes/decodes `AppState` as JSON. Accessed everywhere via `@Environment(PersistenceService.self)`. Use `persistence.update { $0.field = value }` to mutate and auto-save.
- **`AppState`** (Codable struct) — all user state: onboarding status, child name, language preferences, listening sessions, exposure counters, streaks.
- **`SongCatalogService`** — loads `SongCatalog.json` from bundle. Provides `allSongs`, `crossCulturalSongs`, `songsByLanguage()`. Use `audioURL(for:)` to resolve audio file paths (handles the `Audio/` subdirectory prefix).

### Audio Playback
`AudioService` (`@Observable`, `@MainActor`) — wraps `AVAudioPlayer`. For cross-cultural songs, manages 3-segment sequential playback (IT→ZH→EN) with a 0.5s gap between transitions. Handles lock screen Now Playing info via `MPNowPlayingInfoCenter` and remote commands via `MPRemoteCommandCenter`. Audio session configured for `.playback` with `.allowAirPlay`.

### Song Model
Each `Song` has: `id`, `titles` (per language), `lyrics` (timestamped per language), `audioFiles` (path per language), `duration`, `gradient`, `emoji`, `activityPrompts`, `parentNotes`. Cross-cultural songs have 3 audio files; culture-specific songs have 1.

### Screen Flow
Splash → Onboarding (name/languages/speaker) → Home → Player → Activity Bridge → Session Complete → Home. Parent Zone accessible from Home via 3-second hold gate.

### View Organization
- `Views/Home/` — HomeView, DailyMixCard, SongCard, CultureSection
- `Views/Player/` — PlayerView, LyricsView, LanguagePicker, ProgressBar
- `Views/Onboarding/` — OnboardingContainer, NameStep, LanguageStep, SpeakerStep
- `Views/Activity/` — ActivityBridgeView
- `Views/Parent/` or `Views/ParentZone/` — ParentGateView, ParentZoneView, ExposureChart, SettingsView
- `ViewModels/` — HomeViewModel, PlayerViewModel, SessionViewModel

## Key Gotchas

- **pbxproj is hand-managed** — when adding new Swift files, add entries to both the Sources build phase and FileReference sections. IDs use AA/AB/AC/AD/AE/AF prefixes. Current highest IDs: ~AA000036/AB000038/AD000016.
- **Audio and Fonts are folder references** in pbxproj (not file groups) — this preserves subdirectory structure in the bundle.
- **Custom Color statics** — use `Color.bark` explicitly with `.foregroundStyle()`. The shorthand `.foregroundStyle(.bark)` fails because Swift can't infer the Color context. `.background(Color.warm)` works fine.
- **iOS 17 date API** — use `Calendar.current.ordinality(of: .day, in: .year, for:)` instead of `.component(.dayOfYear)` which requires iOS 18.
- **Info.plist is explicit** (not auto-generated) — referenced via `INFOPLIST_FILE` build setting at `TreVoci/Info.plist`.
- **Nunito fonts** — variable font files from Google Fonts GitHub repo (static font URLs 404). Registered in Info.plist under `UIAppFonts`.
- **SourceKit false positives** — editor diagnostics show errors for cross-file references that build fine. Trust the actual build output.

## Audio Files

36 real .m4a files in `TreVoci/Resources/Audio/` with subdirectories: `cross-cultural/`, `italian/`, `chinese/`, `english/`.

Naming: cross-cultural = `{song-id}-{lang}.m4a` (e.g. `frere-jacques-it.m4a`), culture-specific = `{song-id}.m4a` (e.g. `stella-stellina.m4a`).

Spec: AAC, 192kbps, 44.1kHz, stereo, -16 LUFS, 0.5s fade in, 1.0s fade out.

## Coding Standards

- `@Observable` classes marked `@MainActor`
- `@State`, `@Bindable`, `@Environment` — not Combine
- `guard` for early returns, `let` over `var`
- No force unwraps except tests and known-safe `Bundle.main.url`
- Views should not exceed ~150 lines — extract components
- Spring animations: `.animation(.spring(response: 0.4, dampingFraction: 0.8), value:)`
- All interactive elements need `accessibilityLabel`, 44×44pt minimum tap targets
