import SwiftUI

/// A language the app can present.
///
/// **Data-driven, N-language.** The set of supported languages lives in `registry`
/// below — it is NOT a hardcoded enum baked into call sites. The engine iterates
/// `Language.all` (registry order) and the catalog keys its lyrics/audio/titles by a
/// language `code`, so adding a language is: add a registry entry + bundle content
/// keyed by that code (culture-specific songs additionally need a `SongCategory`).
///
/// `.it` / `.zh` / `.en` remain as convenience accessors, but they are registry
/// lookups — not the source of truth.
struct Language: Identifiable, Hashable, Codable {
    let code: String

    init(code: String) { self.code = code }

    var id: String { code }
    var rawValue: String { code }

    /// Failable lookup — only succeeds for a registered language code.
    init?(rawValue: String) {
        guard Language.registry[rawValue] != nil else { return nil }
        self.init(code: rawValue)
    }

    // Encode/decode as the bare code string (matches catalog keys + persisted codes).
    init(from decoder: Decoder) throws {
        self.init(code: try decoder.singleValueContainer().decode(String.self))
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(code)
    }

    private var def: LanguageDef { Language.registry[code] ?? LanguageDef.unknown(code) }

    var displayName: String { def.displayName }
    var flag: String { def.flag }
    var primaryColor: Color { Color(hex: def.primaryHex) }
    var backgroundColor: Color { Color(hex: def.backgroundHex) }
    var familyRole: String { def.familyRole }
    var familyIcon: String { def.familyIcon }
    /// True for non-latin scripts that benefit from romanization (pinyin, etc.).
    var isRomanizable: Bool { def.isRomanizable }
    /// The catalog category holding this language's culture-specific songs.
    var category: SongCategory { def.category }

    /// Every registered language, in canonical presentation order. The engine iterates
    /// this instead of a hardcoded `[.it, .zh, .en]`.
    static let all: [Language] = registryOrder.map(Language.init(code:))
    static var allCases: [Language] { all }

    // Convenience accessors for the seeded languages (registry lookups).
    static let it = Language(code: "it")
    static let zh = Language(code: "zh")
    static let en = Language(code: "en")

    // MARK: - Registry (the data-driven source of truth)

    /// Presentation order of the supported languages.
    static let registryOrder: [String] = ["it", "zh", "en"]

    /// Add an entry here (+ bundle content keyed by the code) to support a new language.
    static let registry: [String: LanguageDef] = [
        "it": LanguageDef(displayName: "Italiano", flag: "🇮🇹",
                          primaryHex: "2A6B45", backgroundHex: "EDF5F0",
                          familyRole: "Papà", familyIcon: "🧔",
                          isRomanizable: false, category: .italian),
        "zh": LanguageDef(displayName: "中文", flag: "🇨🇳",
                          primaryHex: "C43B3B", backgroundHex: "FDF0F0",
                          familyRole: "Māmā", familyIcon: "👩",
                          isRomanizable: true, category: .chinese),
        "en": LanguageDef(displayName: "English", flag: "🇬🇧",
                          primaryHex: "2D5BA9", backgroundHex: "EDF2FA",
                          familyRole: "School", familyIcon: "🏫",
                          isRomanizable: false, category: .english),
    ]
}

/// Static metadata for a registered language.
struct LanguageDef {
    let displayName: String
    let flag: String
    let primaryHex: String
    let backgroundHex: String
    let familyRole: String
    let familyIcon: String
    let isRomanizable: Bool
    let category: SongCategory

    /// Graceful fallback for an unknown code (e.g. content present but not registered).
    static func unknown(_ code: String) -> LanguageDef {
        LanguageDef(displayName: code.uppercased(), flag: "🌐",
                    primaryHex: "8B7E6E", backgroundHex: "F5F0E6",
                    familyRole: code.uppercased(), familyIcon: "🗣️",
                    isRomanizable: false, category: .crossCultural)
    }
}
