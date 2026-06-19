import Foundation

@Observable
@MainActor
final class SessionViewModel {
    private let persistence: PersistenceService
    let song: Song
    let languagesHeard: [Language]
    let durationSeconds: Int

    var phase: Phase = .activity
    var showConfetti = false

    enum Phase {
        case activity
        case summary
    }

    init(song: Song, actualDurationSeconds: Int, persistence: PersistenceService, selectedLanguages: [Language] = Language.all) {
        self.song = song
        self.persistence = persistence
        if song.isCrossCultural {
            self.languagesHeard = Language.all.filter { selectedLanguages.contains($0) }
        } else {
            self.languagesHeard = song.availableLanguages
        }
        self.durationSeconds = actualDurationSeconds
    }

    var childName: String {
        persistence.state.displayName
    }

    var sessionSummaryText: String {
        let minutes = max(1, durationSeconds / 60)
        let langCount = languagesHeard.count
        return "\(minutes) min \u{00B7} \(langCount) language\(langCount > 1 ? "s" : "")"
    }

    func completeActivity() {
        recordSession(completedActivity: true)
        showConfetti = true
        phase = .summary
    }

    func skipActivity() {
        recordSession(completedActivity: false)
        phase = .summary
    }

    private func recordSession(completedActivity: Bool) {
        let session = ListeningSession(
            songId: song.id,
            languagesHeard: languagesHeard.map(\.rawValue),
            durationSeconds: durationSeconds,
            completedActivity: completedActivity
        )
        persistence.update { state in
            state.sessions.append(session)
            let perLang = durationSeconds / max(1, languagesHeard.count)
            for lang in languagesHeard {
                state.totalListeningSeconds[lang.rawValue, default: 0] += perLang
                state.weeklyListeningSeconds[lang.rawValue, default: 0] += perLang
            }

            // Update streak
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            if let lastDate = state.lastSessionDate {
                let lastDay = calendar.startOfDay(for: lastDate)
                let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
                if daysBetween == 1 {
                    state.currentStreak += 1
                } else if daysBetween > 1 {
                    state.currentStreak = 1
                }
                // daysBetween == 0 means same day, no change
            } else {
                state.currentStreak = 1
            }
            state.longestStreak = max(state.longestStreak, state.currentStreak)
            state.lastSessionDate = Date()
        }
    }
}
