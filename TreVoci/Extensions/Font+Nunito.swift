import SwiftUI

enum NunitoWeight: String {
    case extraLight = "Nunito-ExtraLight"
    case light = "Nunito-Light"
    case regular = "Nunito-Regular"
    case medium = "Nunito-Medium"
    case semiBold = "Nunito-SemiBold"
    case bold = "Nunito-Bold"
    case extraBold = "Nunito-ExtraBold"
    case black = "Nunito-Black"

    /// Closest system `Font.Weight`, for non-Latin scripts that fall back to the
    /// system font (which Nunito can't render).
    var systemWeight: Font.Weight {
        switch self {
        case .extraLight: return .ultraLight
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semiBold: return .semibold
        case .bold: return .bold
        case .extraBold: return .heavy
        case .black: return .black
        }
    }
}

extension Font {
    /// Fixed-size Nunito. Prefer the `relativeTo:` variant for any user-facing
    /// text so it honors Dynamic Type.
    static func nunito(_ weight: NunitoWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }

    /// Nunito that scales with the user's Dynamic Type setting, anchored to a
    /// text style. Use for body/title copy a parent reads.
    static func nunito(_ weight: NunitoWeight, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        .custom(weight.rawValue, size: size, relativeTo: style)
    }
}
