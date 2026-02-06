import Foundation

struct Song: Codable, Identifiable {
    let id: String
    let category: SongCategory
    let melodyOrigin: String
    let icon: String
    let backgroundGradient: [String]
    let duration: Int
    let titles: [String: String]
    let audioFiles: [String: String]
    let lyrics: [String: [LyricLine]]
    let activity: Activity
    let parentNote: String

    var isCrossCultural: Bool {
        category == .crossCultural
    }

    func title(for language: Language) -> String {
        titles[language.rawValue] ?? titles["en"] ?? id
    }

    func audioFile(for language: Language) -> String? {
        audioFiles[language.rawValue]
    }

    var availableLanguages: [Language] {
        Language.allCases.filter { audioFiles[$0.rawValue] != nil }
    }

    var primaryLanguage: Language {
        if isCrossCultural { return .it }
        return availableLanguages.first ?? .en
    }

    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

enum SongCategory: String, Codable {
    case crossCultural = "cross-cultural"
    case italian
    case chinese
    case english
}

struct LyricLine: Codable {
    let time: Double
    let text: String
}

struct Activity: Codable {
    let icon: String
    let prompts: [String: String]

    func prompt(for language: Language) -> String {
        prompts[language.rawValue] ?? prompts["en"] ?? ""
    }
}

struct SongCatalogData: Codable {
    let songs: [Song]
}
