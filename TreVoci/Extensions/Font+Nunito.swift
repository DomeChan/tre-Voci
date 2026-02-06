import SwiftUI

enum NunitoWeight: String {
    case regular = "Nunito-Regular"
    case semiBold = "Nunito-SemiBold"
    case bold = "Nunito-Bold"
    case extraBold = "Nunito-ExtraBold"
    case black = "Nunito-Black"
}

extension Font {
    static func nunito(_ weight: NunitoWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}
