import Foundation

struct AppState: Codable {
    var hasCompletedOnboarding: Bool = false
    var childName: String = ""
    var preferredSpeaker: String = "phone"
    var sessionLength: Int = 3
    var dailyMixSeed: String = ""

    // Listening history
    var sessions: [ListeningSession] = []
    var totalListeningSeconds: [String: Int] = ["it": 0, "zh": 0, "en": 0]
    var weeklyListeningSeconds: [String: Int] = ["it": 0, "zh": 0, "en": 0]
    var weekStartDate: Date?

    // Streaks
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastSessionDate: Date?

    // Preferences
    var autoLanguageRotation: Bool = true
    var bedtimeMode: Bool = false

    var displayName: String {
        childName.isEmpty ? "piccola" : childName
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
