import SwiftUI

extension Color {
    // MARK: - Base
    static let cream = Color(hex: "FBF8F1")
    static let warm = Color(hex: "F5F0E6")
    static let sand = Color(hex: "E8E0D0")
    static let bark = Color(hex: "3A3028")
    static let stone = Color(hex: "8B7E6E")
    static let mist = Color(hex: "B8ADA0")

    // MARK: - Language Primaries
    static let italianGreen = Color(hex: "2A6B45")
    static let chineseRed = Color(hex: "C43B3B")
    static let englishBlue = Color(hex: "2D5BA9")

    // MARK: - Language Backgrounds
    static let italianBg = Color(hex: "EDF5F0")
    static let chineseBg = Color(hex: "FDF0F0")
    static let englishBg = Color(hex: "EDF2FA")

    // MARK: - Accents
    static let coral = Color(hex: "FF7B6B")
    static let rose = Color(hex: "FF6B8A")
    static let peach = Color(hex: "FFAD8F")
    static let gold = Color(hex: "FFB84D")

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
