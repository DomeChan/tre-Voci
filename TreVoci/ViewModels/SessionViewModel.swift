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

    init(song: Song, persistence: PersistenceService) {
        self.song = song
        self.persistence = persistence
        if song.isCrossCultural {
            self.languagesHeard = [.it, .zh, .en]
        } else {
            self.languagesHeard = song.availableLanguages
        }
        self.durationSeconds = song.duration
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
        let session = ListeningSession(
            songId: song.id,
            languagesHeard: languagesHeard.map(\.rawValue),
            durationSeconds: durationSeconds,
            completedActivity: true
        )
        persistence.update { state in
            state.sessions.append(session)
            let perLang = durationSeconds / max(1, languagesHeard.count)
            for lang in languagesHeard {
                state.totalListeningSeconds[lang.rawValue, default: 0] += perLang
                state.weeklyListeningSeconds[lang.rawValue, default: 0] += perLang
            }
        }
        showConfetti = true
        phase = .summary
    }

    func skipActivity() {
        let session = ListeningSession(
            songId: song.id,
            languagesHeard: languagesHeard.map(\.rawValue),
            durationSeconds: durationSeconds,
            completedActivity: false
        )
        persistence.update { state in
            state.sessions.append(session)
            let perLang = durationSeconds / max(1, languagesHeard.count)
            for lang in languagesHeard {
                state.totalListeningSeconds[lang.rawValue, default: 0] += perLang
                state.weeklyListeningSeconds[lang.rawValue, default: 0] += perLang
            }
        }
        phase = .summary
    }
}
