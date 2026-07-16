import Foundation

struct AppState: Codable {
    var hasCompletedOnboarding: Bool = false
    var childName: String = ""
    /// Empty until onboarding sets it (onboarding seeds the family's chosen set).
    /// Registry-driven — never a hardcoded language list.
    var selectedLanguages: [String] = []
    var preferredSpeaker: String = "phone"
    var sessionLength: Int = 3
    var dailyMixSeed: String = ""

    // Listening history. Keyed by language code; missing key reads as 0, so these
    // start empty and grow to whatever languages the family actually hears.
    var sessions: [ListeningSession] = []
    var totalListeningSeconds: [String: Int] = [:]
    var weeklyListeningSeconds: [String: Int] = [:]
    var weekStartDate: Date?

    // Streaks
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastSessionDate: Date?

    // Preferences
    var autoLanguageRotation: Bool = true
    var bedtimeMode: Bool = false
    /// True once a parent has explicitly touched the Bedtime Mode toggle in
    /// Settings. Until then, Home auto-arms/disarms bedtimeMode by clock time
    /// (see HomeView's autoArmBedtimeIfNeeded) so the parent it's built for
    /// doesn't have to find a settings toggle at 11pm to get a dimmer screen.
    var bedtimeModeManuallySet: Bool = false

    var displayName: String {
        childName.isEmpty ? "piccola" : childName
    }

    var selectedLanguageSet: Set<Language> {
        Set(selectedLanguages.compactMap { Language(rawValue: $0) })
    }

    func isLanguageSelected(_ lang: Language) -> Bool {
        selectedLanguages.contains(lang.rawValue)
    }
}

struct ListeningSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let songId: String
    let languagesHeard: [String]
    let durationSeconds: Int
    let completedActivity: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        songId: String,
        languagesHeard: [String],
        durationSeconds: Int,
        completedActivity: Bool
    ) {
        self.id = id
        self.date = date
        self.songId = songId
        self.languagesHeard = languagesHeard
        self.durationSeconds = durationSeconds
        self.completedActivity = completedActivity
    }
}
