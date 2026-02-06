import Foundation

#if DEBUG
extension Song {
    static let preview = Song(
        id: "frere-jacques",
        category: .crossCultural,
        melodyOrigin: "Frère Jacques (France, ~1780)",
        icon: "🐯",
        backgroundGradient: ["#FFF3E0", "#FFE0B2"],
        duration: 135,
        titles: ["it": "Fra Martino", "zh": "两只老虎", "en": "Are You Sleeping"],
        audioFiles: [
            "it": "cross-cultural/frere-jacques-it.m4a",
            "zh": "cross-cultural/frere-jacques-zh.m4a",
            "en": "cross-cultural/frere-jacques-en.m4a"
        ],
        lyrics: [
            "it": [LyricLine(time: 0.0, text: "Fra Martino, campanaro")],
            "zh": [LyricLine(time: 0.0, text: "两只老虎 两只老虎")],
            "en": [LyricLine(time: 0.0, text: "Are you sleeping, Brother John?")]
        ],
        activity: Activity(
            icon: "🔔",
            prompts: [
                "it": "Trova una campana! 🔔",
                "zh": "找一个铃铛！🔔",
                "en": "Find something that rings! 🔔"
            ]
        ),
        parentNote: "The Chinese version has completely different lyrics about two tigers!"
    )
}

extension AppState {
    static let preview = AppState(
        hasCompletedOnboarding: true,
        childName: "Sofia"
    )
}

extension PersistenceService {
    static let preview = PersistenceService()
}
#endif
