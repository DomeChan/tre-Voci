# Tre Voci — Technical Product Requirements Document

**Version:** 1.0
**Date:** February 6, 2026
**Author:** Domenico (Guardian AI)
**Status:** Ready for implementation

---

## 1. Product Overview

### 1.1 What It Is
Tre Voci is an audio-first iOS app that helps trilingual toddlers (Italian, Mandarin Chinese, English) maintain exposure to all three languages through nursery rhymes, songs, and guided physical activities. It streams audio to household speakers via AirPlay 2 and is designed to be put down — the screen is for parents to select content, not for children to stare at.

### 1.2 Core Insight
The same beloved melody — Frère Jacques — exists as "Fra Martino Campanaro" in Italian, "两只老虎" (Two Tigers) in Chinese, and "Are You Sleeping" in English. By playing the same song in three languages back-to-back through a Sonos speaker, a toddler absorbs phonological patterns, vocabulary, and rhythm across all three languages in a single 3-minute session.

### 1.3 MVP Scope
- **Single user, single device** — no login, no backend, no accounts
- **Stateful via UserDefaults/local storage** — child name, language config, listening history, session counts
- **36 bundled audio files** — 12 songs × 3 languages
- **AirPlay 2 streaming** via AVFoundation (no Sonos API)
- **No analytics, no tracking, no network calls** in v1
- **iOS only** — iPhone and iPad

### 1.4 Non-Goals for MVP
- Android version
- User accounts / cloud sync
- In-app recording or voice recognition
- Social features / leaderboards
- In-app purchases or donation prompts (add in v1.1)
- CarPlay integration
- Watch app

---

## 2. Technical Architecture

### 2.1 Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Language | Swift 6 | Modern concurrency, native iOS |
| UI Framework | SwiftUI | Declarative, less code, native animations |
| Audio Engine | AVFoundation (AVAudioPlayer + AVQueuePlayer) | Built-in AirPlay 2 support |
| AirPlay | AVRoutePickerView + AVAudioSession | Zero backend, works with all AirPlay 2 speakers |
| Persistence | UserDefaults + Codable JSON file | No database needed for MVP data volume |
| Audio Format | AAC (.m4a) at 192kbps, 44.1kHz | Native iOS decode, good quality-to-size ratio |
| Minimum Target | iOS 17.0 | Covers 95%+ of active devices |
| Architecture | MVVM with ObservableObject | Standard SwiftUI pattern, testable |

### 2.2 Project Structure

```
TreVoci/
├── TreVociApp.swift                 # App entry point
├── Models/
│   ├── Song.swift                   # Song data model
│   ├── Language.swift               # Language enum + metadata
│   ├── Session.swift                # Listening session model
│   ├── ChildProfile.swift           # Child name, age, preferences
│   └── AppState.swift               # Global app state (Codable)
├── ViewModels/
│   ├── PlayerViewModel.swift        # Audio playback + AirPlay control
│   ├── HomeViewModel.swift          # Song library + daily mix logic
│   ├── SessionViewModel.swift       # Session tracking + history
│   └── OnboardingViewModel.swift    # Setup flow state
├── Views/
│   ├── SplashView.swift             # Launch screen
│   ├── Onboarding/
│   │   ├── OnboardingContainer.swift
│   │   ├── NameStep.swift
│   │   ├── LanguageStep.swift
│   │   └── SpeakerStep.swift
│   ├── Home/
│   │   ├── HomeView.swift           # Main content feed
│   │   ├── DailyMixCard.swift       # Hero card
│   │   ├── SongCard.swift           # Individual song tile
│   │   └── CultureSection.swift     # Language-specific song list
│   ├── Player/
│   │   ├── PlayerView.swift         # Full-screen player
│   │   ├── LyricsView.swift         # Animated lyrics display
│   │   ├── LanguagePicker.swift     # IT/ZH/EN toggle pills
│   │   ├── ProgressBar.swift        # Tri-color progress
│   │   └── AirPlayButton.swift      # Speaker picker wrapper
│   ├── Activity/
│   │   ├── ActivityBridgeView.swift # Post-song physical activity prompt
│   │   └── SessionCompleteView.swift # Summary with language checkmarks
│   └── Parent/
│       ├── ParentGateView.swift     # Hold-to-unlock
│       ├── ParentZoneView.swift     # Settings + stats
│       ├── ExposureChart.swift      # Weekly language exposure bars
│       └── SettingsView.swift       # Config options
├── Services/
│   ├── AudioService.swift           # AVAudioPlayer wrapper + AirPlay
│   ├── PersistenceService.swift     # UserDefaults + JSON file I/O
│   └── SessionTracker.swift         # Listening time accumulator
├── Resources/
│   ├── Audio/
│   │   ├── cross-cultural/          # 8 songs × 3 languages = 24 files
│   │   │   ├── frere-jacques-it.m4a
│   │   │   ├── frere-jacques-zh.m4a
│   │   │   ├── frere-jacques-en.m4a
│   │   │   ├── twinkle-it.m4a
│   │   │   └── ... (24 total)
│   │   ├── italian/                 # 4 culture-specific songs
│   │   │   ├── stella-stellina.m4a
│   │   │   ├── batti-batti.m4a
│   │   │   ├── giro-giro-tondo.m4a
│   │   │   └── la-bella-lavanderina.m4a
│   │   ├── chinese/                 # 4 culture-specific songs
│   │   │   ├── xiao-tuzi-guaiguai.m4a
│   │   │   ├── ba-luobo.m4a
│   │   │   ├── zhao-pengyou.m4a
│   │   │   └── da-xiang.m4a
│   │   └── english/                 # 4 culture-specific songs
│   │       ├── humpty-dumpty.m4a
│   │       ├── baa-baa-black-sheep.m4a
│   │       ├── mary-had-a-little-lamb.m4a
│   │       └── itsy-bitsy-spider.m4a
│   ├── SongCatalog.json             # Song metadata (see §3)
│   └── Assets.xcassets/             # App icons, colors
├── Extensions/
│   ├── Color+Theme.swift            # Design tokens
│   └── View+Transitions.swift       # Custom SwiftUI transitions
└── Preview Content/
    └── PreviewData.swift            # Mock data for Xcode previews
```

### 2.3 Dependency Policy
**Zero third-party dependencies.** Everything uses Apple frameworks:
- AVFoundation for audio + AirPlay
- SwiftUI for UI
- Foundation for persistence
- Combine for reactive bindings (optional, can use @Observable)

This eliminates CocoaPods/SPM complexity, ensures App Store compliance, and keeps the project trivially buildable.

---

## 3. Data Models

### 3.1 Song Catalog (SongCatalog.json)

```json
{
  "songs": [
    {
      "id": "frere-jacques",
      "category": "cross-cultural",
      "melodyOrigin": "Frère Jacques (France, ~1780)",
      "icon": "🐯",
      "backgroundGradient": ["#FFF3E0", "#FFE0B2"],
      "duration": 135,
      "titles": {
        "it": "Fra Martino",
        "zh": "两只老虎",
        "en": "Are You Sleeping"
      },
      "audioFiles": {
        "it": "cross-cultural/frere-jacques-it.m4a",
        "zh": "cross-cultural/frere-jacques-zh.m4a",
        "en": "cross-cultural/frere-jacques-en.m4a"
      },
      "lyrics": {
        "it": [
          { "time": 0.0, "text": "Fra Martino, campanaro" },
          { "time": 4.2, "text": "Dormi tu? Dormi tu?" },
          { "time": 8.5, "text": "Suona le campane" },
          { "time": 12.8, "text": "Din don dan, din don dan!" }
        ],
        "zh": [
          { "time": 0.0, "text": "两只老虎 两只老虎" },
          { "time": 4.0, "text": "跑得快 跑得快" },
          { "time": 8.2, "text": "一只没有耳朵" },
          { "time": 12.5, "text": "真奇怪！" }
        ],
        "en": [
          { "time": 0.0, "text": "Are you sleeping, Brother John?" },
          { "time": 4.5, "text": "Morning bells are ringing" },
          { "time": 9.0, "text": "Ding dang dong, ding dang dong!" }
        ]
      },
      "activity": {
        "icon": "🔔",
        "prompts": {
          "it": "Trova una campana! 🔔",
          "zh": "找一个铃铛！🔔",
          "en": "Find something that rings! 🔔"
        }
      },
      "parentNote": "Fun fact: the Chinese version has completely different lyrics about two tigers — one with no ears, one with no tail!"
    }
  ]
}
```

### 3.2 App State (persisted to UserDefaults)

```swift
struct AppState: Codable {
    var hasCompletedOnboarding: Bool = false
    var childName: String = ""
    var preferredSpeaker: String = "phone" // "phone" | "airplay"
    var sessionLength: Int = 3 // number of songs per session
    var dailyMixSeed: String = "" // date string for consistent daily shuffle
    
    // Listening history
    var sessions: [ListeningSession] = []
    var totalListeningSeconds: [String: Int] = ["it": 0, "zh": 0, "en": 0]
    var weeklyListeningSeconds: [String: Int] = ["it": 0, "zh": 0, "en": 0]
    var weekStartDate: Date? = nil
    
    // Preferences
    var autoLanguageRotation: Bool = true // auto-switch IT→ZH→EN during playback
    var bedtimeMode: Bool = false // softer transitions, lullaby-only
}

struct ListeningSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let songId: String
    let languagesHeard: [String] // ["it", "zh", "en"]
    let durationSeconds: Int
    let completedActivity: Bool
}
```

### 3.3 Language Enum

```swift
enum Language: String, Codable, CaseIterable {
    case it, zh, en
    
    var displayName: String {
        switch self {
        case .it: return "Italiano"
        case .zh: return "中文"
        case .en: return "English"
        }
    }
    
    var flag: String {
        switch self {
        case .it: return "🇮🇹"
        case .zh: return "🇨🇳"
        case .en: return "🇬🇧"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .it: return Color(hex: "2A6B45")
        case .zh: return Color(hex: "C43B3B")
        case .en: return Color(hex: "2D5BA9")
        }
    }
}
```

---

## 4. Screen-by-Screen Specification

### 4.1 Splash Screen
**Purpose:** Brand moment, sets warm tone.
**Behavior:**
- Shows on first launch and cold starts only
- Animated flags (🇮🇹 🇨🇳 🇬🇧) with staggered float animation
- App name "Tre Voci" with gradient text
- Subtitle: "Three voices · One song"
- Single CTA button: "Cominciamo! · 开始吧!"
- If `hasCompletedOnboarding == true`, skip directly to Home

### 4.2 Onboarding (3 steps, shown once)

**Step 1 — Child's Name**
- Text input field, placeholder "e.g. Sofia"
- Privacy note: "Never sent anywhere."
- Stored in `AppState.childName`
- Empty string is acceptable (defaults to "piccola" in UI)

**Step 2 — Family Languages**
- Pre-configured display (not editable in MVP):
  - 🧔 Papà speaks → 🇮🇹 Italiano
  - 👩 Māmā speaks → 🇨🇳 中文
  - 🏫 School & together → 🇬🇧 English
- Green checkmarks on each row
- This screen is informational; future versions allow custom OPOL mapping

**Step 3 — Speaker Selection**
- List of audio output options:
  - 📡 AirPlay speakers (discovered via `AVRoutePickerView`)
  - 📱 This iPhone (built-in speaker)
- Selection stored in `AppState.preferredSpeaker`
- AirPlay discovery happens in background; if no speakers found, show only iPhone option

**On completion:** Set `hasCompletedOnboarding = true`, navigate to Home.

### 4.3 Home Screen
**Purpose:** Content discovery, session launcher, daily engagement.

**Layout (top to bottom, scrollable):**
1. **Header** — Greeting ("Buongiorno ☀️"), child's name + "'s Songs", parent zone button (👤 icon, top right)
2. **Speaker Pill** — Small inline indicator showing current output (e.g. "🔊 Living Room Sonos")
3. **Daily Mix Hero Card** — Gradient card showing "3 Songs · 3 Languages · ~12 min · ends with a game". Single "▶ Play Mix" button. The daily mix selects 3 cross-cultural songs, rotating daily (seeded by date).
4. **Cross-Cultural Section** — "🌍 Same Song, Three Worlds" — Horizontal scroll of song cards. Each card shows: emoji icon, English title, Italian + Chinese subtitles, duration.
5. **Italian Section** — "🇮🇹 Filastrocche Italiane" — Vertical list of 4 Italian-only songs.
6. **Chinese Section** — "🇨🇳 中文儿歌" — Vertical list of 4 Chinese-only songs.
7. **English Section** — "🇬🇧 English Nursery Rhymes" — Vertical list of 4 English-only songs.

**Daily Mix Algorithm:**
```swift
func dailyMix(for date: Date) -> [Song] {
    let seed = Calendar.current.startOfDay(for: date).hashValue
    var rng = SeededRandomNumberGenerator(seed: seed)
    return crossCulturalSongs.shuffled(using: &rng).prefix(3).map { $0 }
}
```

### 4.4 Player Screen
**Purpose:** Core experience. Plays a song in up to 3 languages.

**Behavior for cross-cultural songs:**
1. Begins in Italian (papà's language — configurable later)
2. Auto-advances to Chinese at 33% progress
3. Auto-advances to English at 66% progress
4. Each language segment plays the same song file in that language
5. Total session = IT version + ZH version + EN version played sequentially

**Behavior for culture-specific songs (single language):**
- Plays only the single available language version
- No language rotation
- Progress bar is single-color

**UI Elements:**
- **Back button** (top left) — returns to Home, stops playback
- **AirPlay indicator** (top right) — shows "🔊 Sonos" or "📱 iPhone"
- **Song emoji** — large, centered, with breathing animation during playback
- **Title** — current language title, updates on language switch
- **Animated lyrics** — single line, fading in/out, timed to `lyrics[].time` values in JSON. Font size larger for Chinese characters (24pt vs 20pt).
- **Language pills** — 3 toggle buttons (🇮🇹 Italiano | 🇨🇳 中文 | 🇬🇧 English). Active pill highlighted in language color. Tapping manually switches language.
- **Tri-color progress bar** — 3 segments (green/red/blue), each filling as its language plays.
- **Playback controls** — ⏮ (restart), ⏸/▶ (toggle), ⏭ (skip to activity).
- **Language switch toast** — brief notification at top: "🇨🇳 Now playing in 中文" when auto-switching.

**Audio Implementation:**
```swift
class AudioService: ObservableObject {
    private var player: AVAudioPlayer?
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.allowAirPlay])
        try session.setActive(true)
    }
    
    func play(file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    }
    
    // For sequential language playback (cross-cultural songs):
    func playSequence(files: [String], onSegmentChange: @escaping (Int) -> Void) {
        // Uses AVQueuePlayer or chains AVAudioPlayer completion handlers
        // Calls onSegmentChange(0), onSegmentChange(1), onSegmentChange(2)
    }
}
```

**AirPlay Integration:**
```swift
// In SpeakerStep or anywhere speaker selection is needed:
struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.activeTintColor = UIColor(Color.coral)
        picker.prioritizesVideoDevices = false
        return picker
    }
}
```

### 4.5 Activity Bridge Screen
**Purpose:** Natural endpoint. Transitions child from audio to physical play.

**Phase 1 — Activity Prompt:**
- Wiggling activity emoji (e.g. 🔔)
- "Brava {name}! 🎉"
- Trilingual activity prompt card:
  - 🇮🇹 "Trova una campana!"
  - 🇨🇳 "找一个铃铛！"
  - 🇬🇧 "Find something that rings!"
- "Done!" button (trilingual: "Fatto! · 完成了! · Done!")

**Phase 2 — Session Summary:**
- Green checkmark icon
- "Session Complete"
- "{name} heard "{song title}" in 3 languages!"
- Three language badges with ✓ marks
- "Back Home" primary button
- "🎵 One More Song" secondary button

**Session Recording:**
On completing Phase 2, create a `ListeningSession` entry and increment `totalListeningSeconds` and `weeklyListeningSeconds` for each language heard.

### 4.6 Parent Zone

**Parent Gate:**
- Hold-to-unlock button (3 second press)
- Visual fill indicator during hold
- Prevents accidental child access
- "← Back to songs" text link

**Parent Zone Contents (scrollable):**

1. **Exposure Chart** — 3 vertical bars showing minutes per language this week. Dashed line at target (25% of waking hours ≈ 60 min/week per language at minimum). Color-coded: green (IT), red (ZH), blue (EN). Actionable tip: "💡 Mandarin is 38% below Italian. Try a Chinese bedtime song!"

2. **Research Card** — Rotating bilingual family tips based on real research. Example: "Each language needs ~25% of waking input for active production (Montanari, 2013)."

3. **Settings:**
   - Child's name (editable)
   - Default speaker (AirPlay picker)
   - Session length (1/2/3 songs, default 3)
   - Auto language rotation (on/off)
   - Bedtime mode (on/off — lullabies only, dimmed UI)
   - Reset all data

4. **About:**
   - Version number
   - "Open Source · MIT License"
   - "Made with ❤️ in Dubai"
   - Link to GitHub repo

---

## 5. Audio Pipeline

### 5.1 Audio File Specifications

| Property | Value |
|----------|-------|
| Format | AAC (.m4a) |
| Bitrate | 192 kbps |
| Sample Rate | 44,100 Hz |
| Channels | Stereo |
| Loudness | -16 LUFS integrated |
| Loudness Range | LRA ≤ 7 LU |
| True Peak | -2 dBTP |
| Fade In | 0.3 seconds |
| Fade Out | 0.3 seconds |
| Silence | Trimmed from start/end |

### 5.2 File Naming Convention
```
{song-id}-{language-code}.m4a
```
Examples: `frere-jacques-it.m4a`, `twinkle-zh.m4a`, `stella-stellina.m4a`

For culture-specific songs (single language), omit the language code: `stella-stellina.m4a`, `xiao-tuzi-guaiguai.m4a`

### 5.3 Bundle Size Budget
- 36 audio files × ~3.5 MB average = ~126 MB
- SongCatalog.json: <50 KB
- App binary + assets: ~15 MB
- **Total: ~140 MB** (acceptable for App Store)

---

## 6. Song Catalog (Complete)

### 6.1 Cross-Cultural Songs (8 songs × 3 languages = 24 audio files)

| ID | Melody | IT Title | ZH Title | EN Title | Duration |
|----|--------|----------|----------|----------|----------|
| frere-jacques | Frère Jacques (1780) | Fra Martino | 两只老虎 | Are You Sleeping | ~2:15 |
| twinkle | Ah! vous dirai-je, Maman (1761) | Brilla Brilla Stellina | 小星星 | Twinkle Twinkle | ~1:50 |
| old-macdonald | Old MacDonald (1706) | Nella Vecchia Fattoria | 王老先生有块地 | Old MacDonald | ~2:30 |
| if-youre-happy | If You're Happy (~1950s) | Se Sei Felice | 如果感到幸福 | If You're Happy | ~1:45 |
| head-shoulders | Head Shoulders (1912) | Testa Spalle | 头肩膀膝脚趾 | Head Shoulders | ~1:30 |
| happy-birthday | Happy Birthday (1893) | Tanti Auguri | 祝你生日快乐 | Happy Birthday | ~0:45 |
| row-your-boat | Row Your Boat (1852) | Rema Rema Rema | 划船歌 | Row Your Boat | ~1:15 |
| abc-song | Alphabet Song (1835) | Canzone dell'Alfabeto | ABC字母歌 | ABC Song | ~1:30 |

### 6.2 Culture-Specific Songs (12 songs × 1 language = 12 audio files)

**Italian (4):**

| ID | Title | Type | Activity |
|----|-------|------|----------|
| stella-stellina | Stella Stellina | Lullaby | "Chiudi gli occhi e fai un desiderio ✨" |
| batti-batti | Batti Batti le Manine | Clapping rhyme | "Batti le mani più forte! 👏" |
| giro-giro-tondo | Giro Giro Tondo | Circle game | "Gira in tondo! 🔄" |
| la-bella-lavanderina | La Bella Lavanderina | Action song | "Fai finta di lavare! 🧼" |

**Chinese (4):**

| ID | Title | Pinyin | Type | Activity |
|----|-------|--------|------|----------|
| xiao-tuzi-guaiguai | 小兔子乖乖 | Xiǎo Tùzi Guāiguāi | Safety song | "谁在敲门？不要开！🚪" |
| ba-luobo | 拔萝卜 | Bá Luóbo | Story song | "拔呀拔呀拔萝卜！🥕" |
| zhao-pengyou | 找朋友 | Zhǎo Péngyou | Social song | "找一个朋友握握手！🤝" |
| da-xiang | 大象 | Dà Xiàng | Animal song | "用手臂做大象鼻子！🐘" |

**English (4):**

| ID | Title | Type | Activity |
|----|-------|------|----------|
| humpty-dumpty | Humpty Dumpty | Nursery rhyme | "Stack something tall! 🧱" |
| baa-baa-black-sheep | Baa Baa Black Sheep | Nursery rhyme | "Count to three on your fingers! ✋" |
| mary-little-lamb | Mary Had a Little Lamb | Nursery rhyme | "Find something white and fluffy! ☁️" |
| itsy-bitsy-spider | Itsy Bitsy Spider | Action song | "Do the spider crawl with your fingers! 🕷️" |

---

## 7. Design System

### 7.1 Color Tokens

```swift
extension Color {
    // Base
    static let cream = Color(hex: "FBF8F1")
    static let warm = Color(hex: "F5F0E6")
    static let sand = Color(hex: "E8E0D0")
    static let bark = Color(hex: "3A3028")
    static let stone = Color(hex: "8B7E6E")
    static let mist = Color(hex: "B8ADA0")
    
    // Language primaries
    static let italianGreen = Color(hex: "2A6B45")
    static let chineseRed = Color(hex: "C43B3B")
    static let englishBlue = Color(hex: "2D5BA9")
    
    // Language backgrounds
    static let italianBg = Color(hex: "EDF5F0")
    static let chineseBg = Color(hex: "FDF0F0")
    static let englishBg = Color(hex: "EDF2FA")
    
    // Accents
    static let coral = Color(hex: "FF7B6B")
    static let rose = Color(hex: "FF6B8A")
    static let peach = Color(hex: "FFAD8F")
    static let gold = Color(hex: "FFB84D")
}
```

### 7.2 Typography

| Usage | Font | Weight | Size |
|-------|------|--------|------|
| App title | Nunito | Black (900) | 44pt |
| Screen titles | Nunito | Black (900) | 26pt |
| Section headers | Nunito | Black (900) | 17pt |
| Song titles | Nunito | ExtraBold (800) | 15pt |
| Body text | Nunito | SemiBold (600) | 14pt |
| Captions | Nunito | Bold (700) | 12pt |
| Chinese lyrics | System (PingFang SC) | Bold | 24pt |
| Italian/English lyrics | Nunito | ExtraBold | 20pt |

Import Nunito via the app bundle (Google Fonts, OFL license). Fall back to SF Pro Rounded for system contexts.

### 7.3 Corner Radii
- Small (pills, tags): 12pt
- Medium (buttons, inputs, list items): 18pt
- Large (cards): 24pt
- Extra large (hero cards): 32pt

### 7.4 Animations
- **Flag float:** Y translation ±10pt, scale ±10%, 2.4s ease-in-out, staggered 0.3s
- **Song emoji breathing:** scale 1.0 → 1.08, 2.5s ease-in-out
- **Lyric fade:** opacity 0→1 + translateY 6→0, 0.4s ease
- **Language switch toast:** opacity 0→1 + translateY -10→0, 0.35s spring
- **Activity wiggle:** rotation ±10°, 1.2s ease
- **Progress bar segments:** width transition 0.15s linear
- **Screen transitions:** opacity + translateY, 0.4s cubic-bezier(.22,1,.36,1)

---

## 8. Persistence Strategy

### 8.1 UserDefaults Keys

| Key | Type | Description |
|-----|------|-------------|
| `tre_voci_app_state` | Data (JSON) | Full AppState struct |
| `tre_voci_onboarding_complete` | Bool | Quick check to skip splash |

### 8.2 Data Lifecycle

- **On first launch:** Create default AppState, show onboarding
- **On session complete:** Append ListeningSession, update counters
- **On week rollover:** Archive weeklyListeningSeconds to sessions, reset weekly counters
- **On "Reset all data":** Clear UserDefaults keys, show onboarding

### 8.3 Weekly Rollover Logic

```swift
func checkWeekRollover() {
    let calendar = Calendar.current
    let now = Date()
    if let weekStart = state.weekStartDate,
       !calendar.isDate(weekStart, equalTo: now, toGranularity: .weekOfYear) {
        // New week — reset weekly counters
        state.weeklyListeningSeconds = ["it": 0, "zh": 0, "en": 0]
        state.weekStartDate = calendar.startOfDay(for: now)
    }
    if state.weekStartDate == nil {
        state.weekStartDate = calendar.startOfDay(for: now)
    }
}
```

---

## 9. AirPlay 2 Integration

### 9.1 Setup

```swift
func configureAudioSession() {
    let session = AVAudioSession.sharedInstance()
    do {
        try session.setCategory(
            .playback,
            mode: .default,
            options: [.allowAirPlay, .defaultToSpeaker]
        )
        try session.setActive(true)
    } catch {
        print("Audio session setup failed: \(error)")
    }
}
```

### 9.2 Route Picker

Wrap `AVRoutePickerView` in a SwiftUI `UIViewRepresentable`. Place in:
- Onboarding Step 3 (speaker selection)
- Home screen header (speaker pill — tappable)
- Player screen (top right indicator)

### 9.3 Route Change Monitoring

```swift
NotificationCenter.default.addObserver(
    forName: AVAudioSession.routeChangeNotification,
    object: nil, queue: .main
) { notification in
    guard let info = notification.userInfo,
          let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
          let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
    // Update UI to reflect current output device
    let currentRoute = AVAudioSession.sharedInstance().currentRoute
    let outputName = currentRoute.outputs.first?.portName ?? "iPhone"
    // Update speaker indicator
}
```

### 9.4 Key Constraint
AirPlay routing is a **system-level** choice. The app cannot programmatically select a specific speaker — it can only present the picker and reflect the current route. This is fine for MVP.

---

## 10. Testing Strategy

### 10.1 Unit Tests (XCTest)

| Test Area | What to Test |
|-----------|-------------|
| `Song` model | JSON decoding, lyric time sorting, audio file path resolution |
| `AppState` | Codable encode/decode roundtrip, weekly rollover logic |
| `DailyMix` | Same seed → same songs, different dates → different songs |
| `SessionTracker` | Correct duration accumulation, language counting |
| `AudioService` | File existence for all 36 audio files in bundle |

### 10.2 UI Tests (XCUITest)

| Flow | Steps |
|------|-------|
| Onboarding | Launch → name entry → language confirmation → speaker → Home |
| Full session | Home → tap song → player animates → skip to activity → complete → Home |
| Parent zone | Home → parent button → hold gate → unlock → settings visible |
| Daily mix | Launch on different dates → different song selections |

### 10.3 Smoke Test Checklist (Manual)

- [ ] App launches to splash on fresh install
- [ ] Onboarding completes and does not reappear
- [ ] All 36 audio files play without error
- [ ] AirPlay picker appears and routes audio to external speaker
- [ ] Lyrics animate in sync with audio
- [ ] Language auto-rotation works (IT → ZH → EN)
- [ ] Manual language switch works mid-song
- [ ] Activity bridge shows correct trilingual prompts
- [ ] Session complete records to persistence
- [ ] Parent zone unlocks after 3-second hold
- [ ] Exposure chart shows correct weekly data
- [ ] "Reset all data" returns to onboarding
- [ ] App works in airplane mode (all content bundled)
- [ ] Background audio continues when screen locked
- [ ] Now Playing info shows on lock screen

---

## 11. Privacy & Compliance

### 11.1 Data Collection: NONE
- No analytics SDKs
- No crash reporting (use Apple's built-in TestFlight crash logs)
- No network calls
- No PII stored beyond child's first name in local storage
- No advertising identifiers

### 11.2 App Store Privacy Label
- **Data Not Collected** — check this single box

### 11.3 Kids Category Requirements (Apple)
- No third-party analytics
- No third-party advertising
- No links out of the app without parental gate
- No in-app purchases without parental gate
- Age rating: 4+ (suitable for all ages)
- COPPA compliant by design (no data collection)

---

## 12. Future Roadmap (Post-MVP)

| Version | Features |
|---------|----------|
| v1.1 | Donation prompt in Parent Zone (Ko-fi/GitHub Sponsors) |
| v1.2 | Bedtime mode (lullabies only, dim UI, sleep timer) |
| v1.3 | Additional songs (expand to 60+ via cloud download) |
| v2.0 | Android version (Kotlin, ExoPlayer + MediaRouter for Chromecast) |
| v2.1 | Parent pronunciation guide (IPA + audio for non-native parent) |
| v2.2 | Custom OPOL mapping (any 3 languages, not just IT/ZH/EN) |
| v3.0 | Open-source with MIT license on GitHub |
