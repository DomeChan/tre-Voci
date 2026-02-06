import SwiftUI

struct LanguagePicker: View {
    let languages: [Language]
    let activeLanguage: Language
    let onSelect: (Language) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(languages) { language in
                Button {
                    onSelect(language)
                } label: {
                    HStack(spacing: 4) {
                        Text(language.flag)
                            .font(.system(size: 14))
                        Text(language.displayName)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .foregroundStyle(language == activeLanguage ? .white : Color.stone)
                    .background(
                        language == activeLanguage
                            ? AnyShapeStyle(language.primaryColor)
                            : AnyShapeStyle(Color.white.opacity(0.15))
                    )
                    .clipShape(Capsule())
                    .scaleEffect(language == activeLanguage ? 1.05 : 1.0)
                    .shadow(
                        color: language == activeLanguage
                            ? language.primaryColor.opacity(0.3)
                            : .clear,
                        radius: 6, y: 2
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activeLanguage)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(language.displayName), \(language == activeLanguage ? "selected" : "tap to switch")")
                .accessibilityAddTraits(language == activeLanguage ? .isSelected : [])
            }
        }
    }
}

#if DEBUG
#Preview {
    LanguagePicker(
        languages: Language.allCases,
        activeLanguage: .it,
        onSelect: { _ in }
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}
#endif
