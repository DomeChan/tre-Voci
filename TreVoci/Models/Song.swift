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

    // MARK: - Data spine (additive, backward-compatible — all optional)

    /// Energy profile. Drives bedtime filtering, inter-language gap length, and
    /// volume taper. nil decodes as `.playful` via `resolvedEnergy`.
    var energy: SongEnergy?

    /// Approximate tempo in BPM. Informational; tie-breaker for ordering.
    var bpm: Int?

    /// Where each language's recording came from (provenance / credit).
    /// e.g. ["it": "Coccole Sonore", "zh": "宝宝巴士", "en": "Super Simple Songs"].
    var recordingSource: [String: String]?

    /// One shared concept a toddler can latch onto, expressed in each language —
    /// powers the emoji pulse in the player and the parent carry-over phrase.
    /// Present only where a genuine shared concept exists in all three lyrics.
    var echoWord: EchoWord?

    /// Parent-facing "what it means & how to extend it": a carry-over phrase per
    /// language plus a one-line English meaning.
    var parentExtension: ParentExtension?

    var isCrossCultural: Bool {
        category == .crossCultural
    }

    /// Energy with a safe default for songs that predate the data spine.
    var resolvedEnergy: SongEnergy {
        energy ?? .playful
    }

    /// True for songs calm enough to surface in Bedtime Mode.
    var isCalm: Bool {
        resolvedEnergy == .lullaby || resolvedEnergy == .gentle
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
    /// Romanization (pinyin) for non-latin scripts — shown under the line in the
    /// parent pronunciation guide. nil for already-latin lines (Italian/English).
    var romanization: String?
}

/// Energy profile of a song. Ordered roughly calm → energetic; `sortWeight`
/// lets callers order a mix from soothing to lively.
enum SongEnergy: String, Codable {
    case lullaby   // slow, for winding down to sleep
    case gentle    // calm but awake
    case playful   // light and bouncy
    case action    // clap / stomp / move along

    /// Lower = calmer. Used to order Bedtime Mode (and any calm-first list).
    var sortWeight: Int {
        switch self {
        case .lullaby: return 0
        case .gentle:  return 1
        case .playful: return 2
        case .action:  return 3
        }
    }
}

/// A single concept the child can latch onto, in every language the song offers.
/// The player pulses `emoji` when the word is sung; the parent card shows the
/// triple so the family can say it together off-app.
struct EchoWord: Codable {
    /// An emoji standing for the shared concept (pulses on the beat of the word).
    let emoji: String
    /// The word for the concept, per language code (e.g. ["it": "stella", ...]).
    let words: [String: String]
    /// Romanization (pinyin) for non-latin words. nil where already latin.
    var romanization: [String: String]?
    /// First time (seconds) the word is sung, per language — lets the pulse sync.
    var times: [String: Double]?

    func word(for language: Language) -> String? { words[language.rawValue] }
    func romanization(for language: Language) -> String? { romanization?[language.rawValue] }
    func time(for language: Language) -> Double? { times?[language.rawValue] }
}

/// Parent-facing "carry it into the day" content: one short phrase per language
/// the family can reuse, plus a single English line on what it means.
struct ParentExtension: Codable {
    /// A short, reusable phrase per language code.
    let carryPhrase: [String: String]
    /// Romanization of the carry phrase for non-latin languages.
    var carryRomanization: [String: String]?
    /// One English line: what the phrase means / when to use it.
    let meaning: String

    func phrase(for language: Language) -> String? { carryPhrase[language.rawValue] }
    func romanization(for language: Language) -> String? { carryRomanization?[language.rawValue] }
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
