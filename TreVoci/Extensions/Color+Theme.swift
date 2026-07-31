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
    static let plum = Color(hex: "9B59B6")
    /// Same hue as `.coral`, held at low enough lightness to clear text-contrast
    /// minimums on a white background — `.coral` itself (~2.5:1) fails AA there.
    /// Use for coral text/icons on light surfaces (e.g. the Daily Mix Play pill);
    /// `.coral` stays the fill/glow color everywhere else.
    static let coralDeep = Color(hex: "B8422E")

    // MARK: - Bedtime Mode (Night Surface)
    // Same brand hue as .bark/.warm, held at low lightness — not an inverted
    // light mode. Used for the screen-level chrome only; individual song/card
    // surfaces already carry their own self-contained gradient or tint and
    // stay legible floating on a dark canvas without changes.
    static let nightBg = Color(hex: "1C1712")
    static let nightSurface = Color(hex: "241E17")
    static let nightInk = Color(hex: "F2ECE0")
    static let nightStone = Color(hex: "B5A897")

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

// MARK: - Adaptive layout

extension View {
    /// Caps content to a comfortable reading column and centres it horizontally on
    /// large screens (iPad / landscape). On iPhone the content is narrower than the
    /// cap, so this is a no-op there. Keeps the iPhone-first layouts looking designed
    /// on iPad instead of stretching edge-to-edge.
    func readableContentWidth(_ maxWidth: CGFloat = 640) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}
