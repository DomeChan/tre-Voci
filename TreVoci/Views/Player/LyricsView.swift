import SwiftUI

struct LyricsView: View {
    let text: String
    let language: Language

    private var fontSize: CGFloat {
        language == .zh ? 24 : 20
    }

    var body: some View {
        Text(text)
            .font(language == .zh
                  ? .system(size: fontSize, weight: .bold)
                  : .system(size: fontSize, weight: .heavy, design: .rounded))
            .foregroundStyle(language.primaryColor)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .id("\(language.rawValue)-\(text)")
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity
            ))
            .animation(.easeOut(duration: 0.4), value: text)
            .frame(height: 60)
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
