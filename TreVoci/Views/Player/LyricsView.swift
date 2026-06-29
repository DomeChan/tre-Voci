import SwiftUI

struct LyricsView: View {
    let text: String
    let language: Language

    private var fontSize: CGFloat {
        language.usesLatinScript ? 20 : 24   // non-Latin scripts read better a touch larger
    }

    var body: some View {
        Text(text)
            // Script-aware: Nunito for Latin, system font for 中文/العربية (glyph coverage).
            .font(language.font(weight: .extraBold, size: fontSize))
            .environment(\.layoutDirection, language.isRTL ? .rightToLeft : .leftToRight)
            .foregroundStyle(language.primaryColor)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.65)
            .id("\(language.rawValue)-\(text)")
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity
            ))
            .animation(.easeOut(duration: 0.4), value: text)
            .frame(height: 76)
            .accessibilityLabel(text)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 20) {
        LyricsView(text: "Fra Martino, campanaro", language: .it)
        LyricsView(text: "两只老虎 两只老虎", language: .zh)
        LyricsView(text: "Are you sleeping, Brother John?", language: .en)
    }
}
#endif
