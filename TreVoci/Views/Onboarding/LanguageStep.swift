import SwiftUI

struct LanguageStep: View {
    @Binding var selectedLanguages: Set<Language>
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            Text("Choose at least 2 languages")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)
                .multilineTextAlignment(.center)

            Text("but also 3 :) \u{00B7} You can always change this later")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.stone)
                .multilineTextAlignment(.center)

            // Language rows
            VStack(spacing: 12) {
                ForEach(Language.allCases) { lang in
                    languageRow(language: lang)
                }
            }
            .padding(.horizontal, 24)

            // "More languages coming" note
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                Text("More languages coming soon!")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Color.stone)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.sand.opacity(0.5))
            .clipShape(Capsule())

            Spacer()

            // Next button
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(selectedLanguages.count >= 2 ? Color.coral : Color.sand)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .disabled(selectedLanguages.count < 2)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .accessibilityLabel("Next step")
            .accessibilityAddTraits(.isButton)
        }
    }

    private func languageRow(language: Language) -> some View {
        let isSelected = selectedLanguages.contains(language)

        return Button {
            toggleLanguage(language)
        } label: {
            HStack(spacing: 12) {
                Text(language.familyIcon)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(language.familyRole) speaks")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.stone)

                    HStack(spacing: 6) {
                        Text(language.flag)
                            .font(.system(size: 18))
                        Text(language.displayName)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.bark)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? language.primaryColor : Color.sand)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? language.backgroundColor : Color.sand.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(language.displayName), \(isSelected ? "selected" : "not selected")")
        .accessibilityAddTraits(.isButton)
    }

    private func toggleLanguage(_ language: Language) {
        if selectedLanguages.contains(language) {
            // Don't deselect below 2
            guard selectedLanguages.count > 2 else { return }
            selectedLanguages.remove(language)
        } else {
            selectedLanguages.insert(language)
        }
    }
}

#if DEBUG
#Preview {
    LanguageStep(
        selectedLanguages: .constant(Set(Language.all)),
        onNext: {}
    )
}
#endif
