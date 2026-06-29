import SwiftUI

/// A language the app can present.
///
/// **Data-driven, N-language.** The set of supported languages lives in `registry`
/// the bundled `Languages.json` — it is NOT a hardcoded enum baked into call sites.
/// The engine iterates `Language.all` (registry order) and the catalog keys its
/// lyrics/audio/titles by a language `code`, so adding a language is purely data:
/// add a `Languages.json` entry + bundle content keyed by that code (a culture-
/// specific song just sets its `category` to that code — no enum case needed).
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

    private var def: LanguageDef {
        if let d = Language.registry[code] { return d }
        assertionFailure("Unregistered language code '\(code)' — add it to Languages.json")
        return LanguageDef.unknown(code)
    }

    var displayName: String { def.displayName }
    var flag: String { def.flag }
    var primaryColor: Color { Color(hex: def.primaryHex) }
    var backgroundColor: Color { Color(hex: def.backgroundHex) }
    var familyRole: String { def.familyRole }
    var familyIcon: String { def.familyIcon }
    /// True for non-latin scripts that benefit from romanization (pinyin, etc.).
    var isRomanizable: Bool { def.isRomanizable }
    /// Home section header. Defaults to "flag displayName" for any new language.
    var sectionTitle: String { def.sectionTitle ?? "\(flag) \(displayName)" }

    /// Every registered language, in canonical presentation order. The engine iterates
    /// this instead of a hardcoded `[.it, .zh, .en]`.
    static let all: [Language] = registryOrder.map(Language.init(code:))
    static var allCases: [Language] { all }

    // Convenience accessors for the seeded languages (registry lookups).
    static let it = Language(code: "it")
    static let zh = Language(code: "zh")
    static let en = Language(code: "en")

    // MARK: - Registry (the data-driven source of truth)
    //
    // The supported-language set lives in the bundled `Languages.json` resource —
    // adding a language is a data edit (a registry entry + content keyed by that
    // code), no recompile of view logic. The in-code `fallback*` below is only a
    // safety net if the JSON is missing/corrupt, so launch never blanks (P6).

    /// Presentation order of the supported languages (registry order).
    static var registryOrder: [String] { loaded.order }

    /// Every registered language's static metadata, keyed by code.
    static var registry: [String: LanguageDef] { loaded.registry }

    private struct RegistryFile: Codable {
        let order: [String]
        let languages: [String: LanguageDef]
    }

    /// Decoded once from `Languages.json`; falls back to the seeded trio on failure.
    private static let loaded: (order: [String], registry: [String: LanguageDef]) = {
        guard let url = Bundle.main.url(forResource: "Languages", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(RegistryFile.self, from: data),
              !file.order.isEmpty else {
            assertionFailure("Failed to load Languages.json from bundle — using fallback registry")
            return (fallbackOrder, fallbackRegistry)
        }
        return (file.order, file.languages)
    }()

    /// Safety net mirroring the seeded languages, used only if the bundle decode fails.
    private static let fallbackOrder: [String] = ["it", "zh", "en"]
    private static let fallbackRegistry: [String: LanguageDef] = [
        "it": LanguageDef(displayName: "Italiano", flag: "🇮🇹", primaryHex: "2A6B45",
                          backgroundHex: "EDF5F0", familyRole: "Papà", familyIcon: "🧔", isRomanizable: false),
        "zh": LanguageDef(displayName: "中文", flag: "🇨🇳", primaryHex: "C43B3B",
                          backgroundHex: "FDF0F0", familyRole: "Māmā", familyIcon: "👩", isRomanizable: true),
        "en": LanguageDef(displayName: "English", flag: "🇬🇧", primaryHex: "2D5BA9",
                          backgroundHex: "EDF2FA", familyRole: "School", familyIcon: "🏫", isRomanizable: false),
    ]
}

/// Static metadata for a registered language. Decoded from `Languages.json`.
struct LanguageDef: Codable {
    let displayName: String
    let flag: String
    let primaryHex: String
    let backgroundHex: String
    let familyRole: String
    let familyIcon: String
    let isRomanizable: Bool
    /// Optional Home section header; falls back to "flag displayName" if absent.
    var sectionTitle: String? = nil

    /// Graceful fallback for an unknown code (e.g. content present but not registered).
    /// DEBUG builds trip an assertion via `Language.def` so the orphan surfaces loudly.
    static func unknown(_ code: String) -> LanguageDef {
        LanguageDef(displayName: code.uppercased(), flag: "🌐",
                    primaryHex: "8B7E6E", backgroundHex: "F5F0E6",
                    familyRole: code.uppercased(), familyIcon: "🗣️",
                    isRomanizable: false)
    }
}
