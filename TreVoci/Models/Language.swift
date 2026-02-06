import SwiftUI

enum Language: String, Codable, CaseIterable, Identifiable {
    case it, zh, en

    var id: String { rawValue }

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
        case .it: return .italianGreen
        case .zh: return .chineseRed
        case .en: return .englishBlue
        }
    }

    var backgroundColor: Color {
        switch self {
        case .it: return .italianBg
        case .zh: return .chineseBg
        case .en: return .englishBg
        }
    }

    var familyRole: String {
        switch self {
        case .it: return "Papà"
        case .zh: return "Māmā"
        case .en: return "School"
        }
    }

    var familyIcon: String {
        switch self {
        case .it: return "🧔"
        case .zh: return "👩"
        case .en: return "🏫"
        }
    }
}
