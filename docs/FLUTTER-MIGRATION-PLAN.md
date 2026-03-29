# Flutter Migration Plan: Tre Voci

## Context

Tre Voci is a complete iOS app (32 Swift files, ~3,800 LOC) — an audio-first trilingual nursery rhyme player. The current Swift-only implementation can't reach Android users. Porting to Flutter gives cross-platform coverage (iOS + Android) from a single codebase.

The app is feature-complete with real audio files, so this is a **full rewrite** in Dart/Flutter, not an incremental migration. The existing Swift code stays as reference; the Flutter project would live alongside or replace it.

---

## Required Flutter Packages (5 total)

| Package | Replaces | Why needed |
|---------|----------|------------|
| **`just_audio`** | AVAudioPlayer, CADisplayLink | Mature audio player with `ConcatenatingAudioSource` for multi-segment playback, position streams, seek across segments |
| **`audio_service`** | MPNowPlayingInfoCenter, MPRemoteCommandCenter, UIBackgroundModes | Lock screen controls + background audio on both platforms |
| **`shared_preferences`** | UserDefaults | Cross-platform local key-value storage (official Flutter team package) |
| **`provider`** | @Observable + @Environment | State management and DI — maps to existing MVVM pattern |
| **`audio_session`** | AVAudioSession config | Audio category/mode configuration (playback, allow AirPlay) |

No routing, JSON, or animation packages needed — Dart's `dart:convert`, Flutter's built-in animation system, and `Navigator.push` cover everything.

---

## Project Structure

```
tre_voci_flutter/
  lib/
    main.dart                          # Entry point, Provider setup
    app.dart                           # MaterialApp, theme, route config
    models/
      language.dart                    # Language enum (it/zh/en)
      song.dart                        # Song, LyricLine, Activity
      app_state.dart                   # AppState + ListeningSession
    services/
      audio_service.dart               # Multi-segment playback engine
      persistence_service.dart         # SharedPreferences JSON wrapper
      song_catalog_service.dart        # Load SongCatalog.json from assets
    view_models/
      home_view_model.dart             # Daily mix, catalog access
      player_view_model.dart           # Playback state, lyric timing
      session_view_model.dart          # Session recording, streaks
    views/
      splash_view.dart
      onboarding/                      # 3 step onboarding flow
      home/                            # HomeView, DailyMixCard, SongCard, CultureSection
      player/                          # PlayerView, LyricsView, LanguagePicker, ProgressBar
      activity/                        # ActivityBridgeView (activity + summary phases)
      parent_zone/                     # ParentGate, ParentZone, ExposureChart, Settings
      shared/                          # AirPlayPicker (iOS platform view)
    theme/
      colors.dart                      # Hex color constants from Color+Theme.swift
      typography.dart                  # Nunito font weights
  assets/
    audio/                             # All 36 .m4a files in subdirectories
    data/SongCatalog.json
    fonts/Nunito-Variable.ttf
```

---

## Migration Phases

### Phase 1: Foundation
**Port:** Models, theme, persistence, catalog service

- `Language` enum → Dart enum with extension methods for displayName, flag, primaryColor, etc.
- `Song` model → Dart class with `Song.fromJson()` factory (replaces Swift Codable)
- `AppState` + `ListeningSession` → Dart classes with `toJson()`/`fromJson()`
- `Color+Theme.swift` → `colors.dart` with same hex values
- `Font+Nunito.swift` → `typography.dart` + `pubspec.yaml` font declaration
- `PersistenceService` → `ChangeNotifier` wrapping SharedPreferences, same JSON-blob pattern
- `SongCatalogService` → loads from `rootBundle.loadString('assets/data/SongCatalog.json')`
- Set up `MultiProvider` in `main.dart` for PersistenceService + SongCatalogService

**Verification:** Unit tests — JSON round-trip for all models, catalog loads 20 songs, persistence save/load/reset works.

### Phase 2: Audio Core (highest risk)
**Port:** AudioService, PlayerViewModel

Key architectural difference: **streams replace polling**.

- Current Swift: `CADisplayLink` polls AVAudioPlayer at 15fps, computes cumulative time across segments manually
- Flutter: `just_audio` provides `positionStream`, `currentIndexStream`, `playerStateStream` — reactive, no polling needed

**Multi-segment playback approach:**
```dart
final playlist = ConcatenatingAudioSource(children: [
  AudioSource.asset('assets/audio/cross-cultural/frere-jacques-it.m4a'),
  SilenceAudioSource(duration: Duration(milliseconds: 500)),  // gap
  AudioSource.asset('assets/audio/cross-cultural/frere-jacques-zh.m4a'),
  SilenceAudioSource(duration: Duration(milliseconds: 500)),  // gap
  AudioSource.asset('assets/audio/cross-cultural/frere-jacques-en.m4a'),
]);
```

**Critical gotcha:** Playlist indices include silence sources. Must map playlist index → language segment index (real segments at indices 0, 2, 4; silence at 1, 3). Build a lookup table when constructing the playlist.

**Lyric timing simplification:** `just_audio`'s `position` within a `ConcatenatingAudioSource` gives position *within the current child source* — so lyric lookup is already segment-local. No need for the `currentTime - segmentStartTime()` calculation.

**Lock screen / background audio:**
- Implement `AudioHandler` (extends `BaseAudioHandler` from `audio_service`)
- Forward play/pause/skipToNext/skipToPrevious to `just_audio` player
- Update `mediaItem` on segment change for correct Now Playing info
- iOS: add `UIBackgroundModes: [audio]` in `ios/Runner/Info.plist`
- Android: `audio_service` auto-creates foreground service; add `FOREGROUND_SERVICE_MEDIA_PLAYBACK` and `WAKE_LOCK` permissions in AndroidManifest.xml

**Verification:** Build minimal player screen, verify: play/pause, multi-segment transitions with gap, seek across segments, lock screen controls on both platforms.

### Phase 3: Main UI Screens
**Port:** SplashView, Onboarding (3 steps), HomeView + subcomponents

SwiftUI → Flutter mapping:
- `VStack`/`HStack`/`ZStack` → `Column`/`Row`/`Stack`
- `ScrollView` → `SingleChildScrollView` or `ListView`
- `GeometryReader` → `LayoutBuilder`
- `.animation(.spring(...), value:)` → `AnimatedContainer` or explicit `AnimationController`
- `withAnimation {}` → wrap state change, use `AnimatedSwitcher` or implicit animations
- `.fullScreenCover(item:)` (SheetDestination enum) → `Navigator.push(MaterialPageRoute(fullscreenDialog: true))`
- `@Environment(PersistenceService.self)` → `context.watch<PersistenceService>()`

**Navigation:** The `SheetDestination` enum pattern maps to pushing named/typed routes. Player → Activity transition (dismiss player, present activity after delay) becomes `Navigator.pushReplacement`.

**Verification:** Full onboarding flow persists state, home shows all 20 songs in 4 sections, daily mix deterministic.

### Phase 4: Player & Activity
**Port:** Full PlayerView, LyricsView, LanguagePicker, ProgressBar, ActivityBridgeView, SessionViewModel

**ProgressBar** — the most complex widget to port:
- Tri-color segmented track → `CustomPainter` drawing colored `RRect` segments
- Draggable glass thumb → `GestureDetector` with `onHorizontalDragUpdate`
- Spring animation on thumb → `SpringSimulation` with `AnimationController`

**Breathing emoji** → `AnimationController` with `repeat(reverse: true)` driving a `ScaleTransition`

**Lyric transitions** → `AnimatedSwitcher` with `FadeTransition` + `SlideTransition`, keyed on `"$lang-$lyricIndex"`

**Confetti animation** in ActivityBridge → `AnimationController` driving multiple `Transform` widgets with random offsets

**Verification:** Full flow Home → Player → Activity → Summary → Home. Lyrics sync, segments transition, session recorded.

### Phase 5: Parent Zone
**Port:** ParentGateView, ParentZoneView, ExposureChart, SettingsView

**3-second hold gate:** `GestureDetector` with `onLongPressStart`/`onLongPressEnd` + `Timer.periodic` for progress animation. `CustomPainter` for conic gradient ring.

**Exposure chart (concentric rings):** `CustomPainter` with `canvas.drawArc()` for each language ring. This is the trickiest visual port — the SwiftUI version uses `trim(from:to:)` on `Circle()` shapes.

**Settings:** Standard `ListView` with form elements — straightforward Flutter `Switch`, `Slider`, `TextField`.

### Phase 6: Platform Polish

**AirPlay (iOS only):** Embed `AVRoutePickerView` via `UiKitView` / `PlatformViewLink` — same invisible-overlay trick as current Swift code. On Android, omit this and let users use the system media output picker.

**App icons:** Use `flutter_launcher_icons` (dev dependency) or manually place icons in `ios/` and `android/` asset directories.

**Emoji rendering:** Test flag emojis on multiple Android devices — they render differently across manufacturers. Consider using Unicode flag sequences with fallback text.

**Variable font:** Verify all 5 Nunito weights render correctly. Fallback plan: bundle static weight .ttf files.

---

## What Translates Directly vs. Needs Rethinking

| Aspect | Direct port | Needs rethinking |
|--------|-------------|-----------------|
| Models (Song, AppState, Language) | Yes — mechanical translation to Dart classes | |
| SongCatalog.json | Yes — copy as-is, same schema | |
| Audio files | Yes — copy all 36 .m4a files | |
| Persistence logic | Yes — same JSON-blob pattern | |
| Streak/exposure math | Yes — pure date arithmetic | |
| Daily mix seeded RNG | Yes — same algorithm in Dart | |
| | | AudioService — poll-based → stream-based |
| | | Navigation — SheetDestination enum → Navigator routes |
| | | Animations — declarative implicit → explicit controllers |
| | | ProgressBar — GeometryReader + gestures → CustomPainter + GestureDetector |
| | | ExposureChart — trim on Circle → CustomPainter arcs |
| | | AirPlay picker — platform-specific, iOS only in Flutter |
| | | Material/blur effects — .ultraThinMaterial → BackdropFilter approximation |

---

## Key Risks

1. **Audio segment gaps** — `SilenceAudioSource` interleaving changes playlist index math. Must map playlist indices to language indices carefully.
2. **Seek across segments** — `just_audio` supports `seek(position, index: idx)` but need to account for silence sources when calculating target index from normalized progress.
3. **AirPlay on iOS** — `UiKitView` embedding of `AVRoutePickerView` can have z-ordering/touch issues in Flutter. Test early.
4. **Background audio on Android** — foreground service permissions changed in Android 14. Must target correct permissions.
5. **App size** — 85MB of audio is fine (Play Store limit 150MB AAB base), but test asset bundling on both platforms.
6. **Animation fidelity** — SwiftUI implicit animations are effortless; Flutter explicit controllers need manual lifecycle management (`dispose()`). Budget extra time.

---

## Verification Plan

1. **Unit tests:** Model JSON round-trips, catalog loading (20 songs), persistence save/load/reset, streak logic, daily mix determinism
2. **Widget tests:** Each major screen renders without error, gesture interactions (progress bar seek, parent gate hold)
3. **Integration test:** Full user flow on both iOS and Android simulators/emulators
4. **Audio test:** All 36 files play, multi-segment transitions work, lock screen controls function
5. **Platform test:** Background audio survives app minimize, AirPlay picker works on iOS, Android notification controls work

---

## Estimated Scope

- ~3,800 lines of Swift → roughly **4,500–5,500 lines of Dart** (Flutter is slightly more verbose than SwiftUI for layouts, but simpler for audio streams)
- 5 packages (vs. 0 in Swift — packages are unavoidable in Flutter for audio and platform integration)
- The audio service and player are the hardest pieces; the rest is mechanical UI translation
