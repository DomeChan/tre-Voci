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
