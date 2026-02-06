# CLAUDE.md — Tre Voci iOS App Build Instructions

## You are building Tre Voci, an audio-first trilingual nursery rhyme app for iOS.

Read the full PRD at `docs/TRE-VOCI-PRD.md` before writing any code. This file contains your autonomous build plan, verification steps, and quality gates.

---

## PROJECT CONTEXT

**What:** iOS app that plays nursery rhymes in Italian, Mandarin Chinese, and English. Streams to Sonos/HomePod via AirPlay 2. Designed for a 2-year-old in a trilingual household (Italian father, Chinese mother, English school in Dubai).

**Who:** Solo developer (Domenico), experienced iOS dev, founder of Guardian AI (YC-backed). He will provide the 36 audio files separately — use placeholder/silent audio files during development and structure the project so dropping in real .m4a files is trivial.

**Constraints:**
- Zero third-party dependencies (no SPM, no CocoaPods — Apple frameworks only)
- Swift 6, SwiftUI, iOS 17+
- MVVM architecture with @Observable (not ObservableObject)
- No network calls, no analytics, no tracking
- All content bundled in app
- No login, no accounts — local state only via UserDefaults

---

## BUILD PLAN — EXECUTE IN THIS ORDER

### Phase 1: Project Scaffold

1. Create new Xcode project named `TreVoci` with bundle ID `com.trevoci.app`
2. Set deployment target to iOS 17.0
3. Set up the folder structure exactly as specified in PRD §2.2
4. Create `Color+Theme.swift` with all design tokens from PRD §7.1
5. Create `Language.swift` enum with all properties from PRD §3.3
6. Create `Song.swift` Codable model matching the JSON schema in PRD §3.1
7. Create `AppState.swift` and `ListeningSession.swift` from PRD §3.2
8. Create `SongCatalog.json` with ALL 20 songs (8 cross-cultural + 4 Italian + 4 Chinese + 4 English). Include complete metadata: titles, lyrics with timestamps, activity prompts, background gradients, parent notes. Use the full song data from PRD §6.
9. Create `PersistenceService.swift` — simple UserDefaults wrapper that encodes/decodes AppState as JSON

**Verification gate:**
```bash
# Build succeeds with no warnings
xcodebuild -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
# Should see: BUILD SUCCEEDED
```

### Phase 2: Audio Infrastructure

1. Create placeholder audio files — generate 36 silent .m4a files (2 seconds each) using the exact filenames from PRD §5.2:
```bash
# If ffmpeg available:
for song in frere-jacques twinkle old-macdonald if-youre-happy head-shoulders happy-birthday row-your-boat abc-song; do
  for lang in it zh en; do
    ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 2 -c:a aac -b:a 192k "Audio/cross-cultural/${song}-${lang}.m4a" 2>/dev/null
  done
done
# Culture-specific (single language)
for song in stella-stellina batti-batti giro-giro-tondo la-bella-lavanderina; do
  ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 2 -c:a aac -b:a 192k "Audio/italian/${song}.m4a" 2>/dev/null
done
for song in xiao-tuzi-guaiguai ba-luobo zhao-pengyou da-xiang; do
  ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 2 -c:a aac -b:a 192k "Audio/chinese/${song}.m4a" 2>/dev/null
done
for song in humpty-dumpty baa-baa-black-sheep mary-little-lamb itsy-bitsy-spider; do
  ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 2 -c:a aac -b:a 192k "Audio/english/${song}.m4a" 2>/dev/null
done
```
   If ffmpeg is not available, create empty .m4a files or use a Swift script to generate silent audio with AVFoundation.

2. Add all audio files to the Xcode project's Resources/Audio/ groups, ensuring they're included in the app bundle target.

3. Create `AudioService.swift`:
   - Wraps `AVAudioPlayer` for single file playback
   - Implements sequential playback for cross-cultural songs (IT→ZH→EN)
   - Configures `AVAudioSession` for `.playback` category with `.allowAirPlay`
   - Publishes: `isPlaying: Bool`, `currentTime: TimeInterval`, `duration: TimeInterval`, `progress: Double` (0.0-1.0), `currentSegment: Int` (0/1/2 for language index)
   - Provides: `play()`, `pause()`, `stop()`, `skipToSegment(index:)`, `restart()`
   - Handles audio interruptions (phone calls) gracefully
   - Sets Now Playing info on lock screen via `MPNowPlayingInfoCenter`

4. Create `SongCatalogService.swift`:
   - Loads `SongCatalog.json` from bundle
   - Provides `allSongs`, `crossCulturalSongs`, `songsByLanguage(_ lang:)`, `song(byId:)`
   - Validates that every referenced audio file exists in bundle at init time (assert in debug)

**Verification gate:**
```bash
# Build and run unit test that verifies all 36 audio files exist in bundle
xcodebuild test -scheme TreVoci -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:TreVociTests/AudioFileExistenceTests 2>&1 | grep -E "(Test Case|passed|failed)"
```

Write this test:
```swift
final class AudioFileExistenceTests: XCTestCase {
    func testAllAudioFilesExistInBundle() {
        let catalog = SongCatalogService()
        for song in catalog.allSongs {
            for (lang, path) in song.audioFiles {
                let url = Bundle.main.url(forResource: path.replacingOccurrences(of: ".m4a", with: ""),
                                          withExtension: "m4a",
                                          subdirectory: nil)
                XCTAssertNotNil(url, "Missing audio file: \(path) for song \(song.id) language \(lang)")
            }
        }
    }
}
```

### Phase 3: Core Views — Splash + Onboarding

1. Create `SplashView.swift`:
   - Gradient background: radial from #FFF5EB to #FDE8D5 to #E5D8F0
   - Centered 🎵 icon in frosted glass container (110×110, radius 36)
   - "Tre Voci" title with gradient text (coral → rose → gold)
   - "Three voices · One song" subtitle in caps, letter-spacing 2.5
   - Three flags with staggered float animation (use `.animation(.easeInOut(duration: 2.4).repeatForever(), value: animate)` with delay)
   - Primary button: "Cominciamo! · 开始吧!"
   - Skip if `AppState.hasCompletedOnboarding`

2. Create `OnboardingContainer.swift` + 3 step views:
   - Animated step dots (active dot wider: 28pt vs 8pt)
   - Fade+slide transitions between steps
   - **NameStep:** TextField for child name, privacy note
   - **LanguageStep:** 3 pre-configured rows (Papà→IT, Māmā→ZH, School→EN) with language-colored backgrounds and checkmarks
   - **SpeakerStep:** List of output options. Wrap `AVRoutePickerView` in `UIViewRepresentable`. Include "This iPhone" fallback.
   - Final button: "Pronti! · 准备好了!" → sets `hasCompletedOnboarding = true`, navigates to Home

3. Create navigation root in `TreVociApp.swift`:
   - Check `AppState.hasCompletedOnboarding`
   - If false → SplashView → OnboardingContainer → HomeView
   - If true → HomeView directly
   - Use `@State` or `NavigationStack` for flow control

**Verification gate:**
- Run in simulator. Tap through onboarding. Force quit. Relaunch. Should go directly to Home.
- Enter a name. Complete onboarding. Check that name appears on Home screen.

### Phase 4: Home Screen

1. Create `HomeView.swift`:
   - ScrollView with vertical content
   - Pull design exactly from PRD §4.3

2. Create `DailyMixCard.swift`:
   - Gradient hero card (coral → rose → purple)
   - Decorative semi-transparent circles
   - Shows session info: "3 Songs · 3 Languages · ~12 min"
   - "▶ Play Mix" button

3. Create `SongCard.swift`:
   - Used in horizontal ScrollView
   - Background gradient from song data
   - Emoji, EN title, IT+ZH subtitles, duration
   - Tappable → navigates to Player

4. Create `CultureSection.swift`:
   - Reusable component for language-specific song lists
   - Takes `language: Language` and `songs: [Song]`
   - Vertical list with language-colored backgrounds

5. Create `HomeViewModel.swift`:
   - `dailyMix` computed property using date-seeded shuffle
   - Exposes `crossCulturalSongs`, `italianSongs`, `chineseSongs`, `englishSongs`
   - Reads child name from AppState

**Verification gate:**
- Home screen renders all 4 sections
- Horizontal scroll works on cross-cultural cards
- Daily mix shows 3 different songs
- Speaker pill shows correct output

### Phase 5: Player Screen

This is the most complex screen. Build it carefully.

1. Create `PlayerViewModel.swift`:
   - Owns an `AudioService` instance
   - Manages: `currentLanguage: Language`, `isPlaying: Bool`, `progress: Double`, `currentLyricIndex: Int`
   - For cross-cultural songs: manages 3-segment playback
     - Segments: 0=IT, 1=ZH, 2=EN
     - On segment completion → auto-advance to next language
     - On final segment completion → trigger navigation to Activity
   - For culture-specific songs: single segment, single language
   - Lyric timing: compare `currentTime` against `lyrics[lang][i].time` to determine active lyric
   - Manual language switch: `switchLanguage(_ lang: Language)` — stops current, starts new language version from beginning

2. Create `PlayerView.swift`:
   - Full-screen view with song gradient background
   - Back button (top left, frosted glass)
   - AirPlay indicator (top right, frosted glass)
   - Large centered emoji with breathing animation
   - Song title in current language + melody subtitle
   - `LyricsView` — single animated line, fades between lyrics
   - `LanguagePicker` — 3 pills, active one highlighted in language color with shadow
   - `ProgressBar` — tri-color segments (or single color for culture-specific)
   - Language segment labels below progress bar
   - Playback controls: ⏮ ⏸/▶ ⏭
   - Language switch toast notification (top center, animated)

3. Create `LyricsView.swift`:
   - Displays one lyric line at a time
   - Font size: 24pt for Chinese, 20pt for Italian/English
   - Color: language primary color
   - Animation: fade in + slide up on change
   - Key the view on `"\(lang)-\(lyricIndex)"` to trigger animation

4. Create `LanguagePicker.swift`:
   - Horizontal row of 3 capsule buttons
   - Active: language color background, white text, slight scale + shadow
   - Inactive: transparent, gray text

5. Create `ProgressBar.swift`:
   - For cross-cultural: 3 equal segments, each fills with its language color
   - Segment fills based on: `progress < 0.33 → segment 0 active`, etc.
   - For culture-specific: single segment in language color

**Verification gate:**
- Tap any song on Home → Player opens
- Play/pause works
- Language pills switch active language
- Progress bar advances
- Lyrics animate (will show placeholder text since audio is silent, but structure works)
- Skip button → navigates to Activity
- Back button → returns to Home

### Phase 6: Activity Bridge + Session Complete

1. Create `ActivityBridgeView.swift`:
   - Phase 1: Activity prompt
     - Wiggling emoji (rotation animation ±10°)
     - "Brava {name}! 🎉"
     - White card with 3 language prompts (flag + text per row)
     - "Done!" trilingual button
   - Phase 2: Session summary
     - Green checkmark in rounded container
     - Session info text
     - 3 language badges with ✓
     - "Back Home" primary + "One More Song" secondary buttons

2. Create `SessionViewModel.swift`:
   - `completeSession(song:, languagesHeard:, duration:)` — creates ListeningSession, updates counters
   - Called when user taps "Done!" on activity

**Verification gate:**
- Complete full flow: Home → Song → Player → Activity → Summary → Home
- Check that AppState.sessions has a new entry after completion
- Check that weeklyListeningSeconds incremented

### Phase 7: Parent Zone

1. Create `ParentGateView.swift`:
   - 🔒 icon in rounded container
   - Hold-to-unlock button (80×80 circle)
   - Use `LongPressGesture(minimumDuration: 3)` combined with `DragGesture(minimumDistance: 0)` for visual progress
   - Conic gradient fill animates during hold
   - On success → navigate to ParentZoneView
   - "← Back to songs" text link

2. Create `ParentZoneView.swift`:
   - ScrollView with sections:
   - Header with back button

3. Create `ExposureChart.swift`:
   - 3 vertical bars (IT green, ZH red, EN blue)
   - Height proportional to minutes
   - Dashed target line
   - Minutes label inside each bar
   - Tip card with actionable advice (compare ZH vs IT, suggest actions)

4. Create `SettingsView.swift`:
   - List of settings rows
   - Child's name (inline editable)
   - Default speaker (AirPlay picker button)
   - Session length (1/2/3 stepper)
   - Auto language rotation toggle
   - Bedtime mode toggle
   - Reset all data (with confirmation alert)
   - About section (version, license, location)

**Verification gate:**
- Parent zone requires 3-second hold
- Releasing early resets progress
- Exposure chart renders with mock data
- Settings changes persist across app restarts
- "Reset all data" shows onboarding on next launch

### Phase 8: Polish + Integration Testing

1. **Now Playing lock screen integration:**
```swift
import MediaPlayer

func updateNowPlaying(song: Song, language: Language) {
    var info = [String: Any]()
    info[MPMediaItemPropertyTitle] = song.titles[language.rawValue]
    info[MPMediaItemPropertyArtist] = "Tre Voci"
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
    info[MPMediaItemPropertyPlaybackDuration] = player.duration
    info[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
}
```

2. **Remote control handling** (lock screen play/pause):
```swift
let commandCenter = MPRemoteCommandCenter.shared()
commandCenter.playCommand.addTarget { _ in self.play(); return .success }
commandCenter.pauseCommand.addTarget { _ in self.pause(); return .success }
commandCenter.nextTrackCommand.addTarget { _ in self.skipToNext(); return .success }
```

3. **Background audio:**
   - Add `audio` to `UIBackgroundModes` in Info.plist
   - Ensure `AVAudioSession` category is `.playback`

4. **App icon:**
   - Create a simple app icon: 🎵 emoji concept on warm gradient
   - Use 1024×1024 asset for App Store, auto-generate sizes
   - If you can't generate images, create a placeholder colored square

5. **Launch screen:**
   - Cream background (#FBF8F1) in LaunchScreen storyboard or Info.plist background color

6. **Font registration:**
   - Download Nunito font files (Regular, SemiBold, Bold, ExtraBold, Black) from Google Fonts
   - Add to project bundle
   - Register in Info.plist under `UIAppFonts`
   - Create Font extension for easy access:
   ```swift
   extension Font {
       static func nunito(_ weight: NunitoWeight, size: CGFloat) -> Font {
           .custom(weight.fontName, size: size)
       }
   }
   ```

**Verification gate:**
Run the complete smoke test checklist:
- [ ] Fresh install → Splash → Onboarding → Home (correct flow)
- [ ] Onboarding state persists across launches
- [ ] All 20 songs visible on Home screen
- [ ] Daily mix rotates (change device date to verify)
- [ ] Player opens for cross-cultural song → 3 language segments
- [ ] Player opens for culture-specific song → 1 language segment
- [ ] Language pills switch playback
- [ ] Progress bar reflects correct segment
- [ ] Lyrics view updates
- [ ] ⏮ restarts, ⏸/▶ toggles, ⏭ skips to activity
- [ ] Activity bridge shows correct prompts for the song
- [ ] Session complete records data
- [ ] Parent gate blocks access until 3s hold
- [ ] Exposure chart shows accumulated data
- [ ] Settings persist
- [ ] Reset clears everything
- [ ] AirPlay picker appears on tap
- [ ] Background audio works (lock screen)
- [ ] Now Playing info on lock screen
- [ ] No crashes on any screen
- [ ] No network calls (verify with Network Link Conditioner off)

---

## CODING STANDARDS

### Swift Style
- Use `@Observable` (iOS 17+) not `ObservableObject`
- Use `@State`, `@Bindable`, `@Environment` appropriately
- Prefer `let` over `var`
- Use `guard` for early returns
- Mark view model classes as `@MainActor`
- Use `async/await` for any asynchronous work
- No force unwraps (`!`) except in tests and known-safe Bundle.main.url

### SwiftUI Patterns
- Extract reusable components (don't let any view exceed ~150 lines)
- Use `ViewModifier` for repeated styling patterns
- Use `PreferenceKey` sparingly — prefer simpler state passing
- Use `.animation(.spring(response: 0.4, dampingFraction: 0.8), value: X)` for UI animations
- Use `withAnimation { }` for state-triggered transitions

### File Organization
- One type per file (with private helpers)
- Group related extensions in the same file
- Keep `TreVociApp.swift` minimal — just the @main entry and root navigation

### Error Handling
- Audio file missing → fall through gracefully, show empty state
- JSON decode failure → crash in debug (assert), fallback to empty catalog in release
- UserDefaults corruption → reset to defaults

### Accessibility
- Add `accessibilityLabel` to all interactive elements
- Use `accessibilityAddTraits(.isButton)` on tappable elements
- VoiceOver: all emojis should have descriptive labels
- Dynamic Type: test at largest text sizes (lyrics may need ScrollView)
- Minimum tap target: 44×44 points

---

## AUDIO FILE REPLACEMENT

When real audio files are ready, replace them by:

1. Remove placeholder files from `Resources/Audio/` subdirectories
2. Copy real .m4a files with exact same filenames
3. Update `SongCatalog.json` with actual durations and corrected lyric timestamps
4. Rebuild — no code changes needed

The audio file naming convention is:
- Cross-cultural: `{song-id}-{lang}.m4a` → `frere-jacques-it.m4a`
- Culture-specific: `{song-id}.m4a` → `stella-stellina.m4a`

All files must be AAC, 192kbps, 44.1kHz, stereo, -16 LUFS. See the Audio Sourcing Guide for the complete ffmpeg processing pipeline.

---

## SELF-TEST PROTOCOL

After completing each phase, run these checks before proceeding:

```
1. Does it build? (xcodebuild build — zero errors, zero warnings)
2. Does it run? (launch in simulator — no crashes)
3. Does the new feature work? (manual tap-through of the feature)
4. Does the old stuff still work? (tap through previous features)
5. Did I break persistence? (force quit → relaunch → state preserved)
```

For the final integration test, record a screen recording of the complete user flow:
Launch → Onboarding → Home → Play Mix → Player (auto-rotate IT→ZH→EN) → Activity → Complete → Home → Parent Zone → Exposure Chart → Settings → Back

This recording serves as the acceptance test artifact.

---

## KNOWN LIMITATIONS (ACCEPTABLE FOR MVP)

- Audio files are placeholders (silent) — real content added manually later
- AirPlay works but speaker selection is system-level (can't auto-connect)
- No lyric sync accuracy (timestamps are approximate — will be tuned with real audio)
- Weekly rollover is calendar-based, not ISO week
- No iPad-specific layout optimization (works, but not optimized)
- No landscape support (portrait locked)
- Exposure chart uses mock data until enough real sessions accumulate
- No localization of app UI (hardcoded trilingual strings inline)
