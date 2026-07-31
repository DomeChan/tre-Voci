import SwiftUI

struct LanguageStep: View {
    @Binding var selectedLanguages: Set<Language>
    let onNext: () -> Void

    private let catalog = SongCatalogService()

    /// How many songs a child would actually hear in this language (culture-
    /// specific + any cross-cultural song that offers it). Drives honest counts.
    private func songCount(_ language: Language) -> Int {
        catalog.allSongs.filter { $0.audioFiles[language.code] != nil }.count
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 8)

            // Title
            Text("Choose at least 2 languages")
                .font(.nunito(.black, size: 24))
                .foregroundStyle(Color.bark)
                .multilineTextAlignment(.center)

            Text("but also 3 :) \u{00B7} You can always change this later")
                .font(.nunito(.semiBold, size: 14))
                .foregroundStyle(Color.stone)
                .multilineTextAlignment(.center)

            // Language rows — scrollable so the registry can keep growing
            // (Languages.json) without the Next button getting pushed off
            // the bottom of shorter screens.
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Language.allCases) { lang in
                        languageRow(language: lang)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 4)
            }

            // "More languages coming" note
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                Text("More languages coming soon!")
                    .font(.nunito(.semiBold, size: 12))
            }
            .foregroundStyle(Color.stone)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.sand.opacity(0.5))
            .clipShape(Capsule())

            // Next button
            Button(action: onNext) {
                Text("Next")
                    .font(.nunito(.bold, size: 17))
                    .foregroundStyle(Color.bark)
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
        let count = songCount(language)
        let hasContent = count > 0

        return Button {
            toggleLanguage(language)
        } label: {
            HStack(spacing: 14) {
                // Flag carries identity; the name is on the row's accessibilityLabel.
                Text(language.flag)
                    .font(.system(size: 34))

                // Honest content count — "coming soon" when a registered
                // language has no real recordings yet (P10).
                Text(hasContent ? "\(count) songs" : "coming soon")
                    .font(.nunito(.semiBold, size: 13))
                    .foregroundStyle(Color.stone)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? language.primaryColor : Color.sand)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? language.backgroundColor : Color.sand.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .opacity(hasContent ? 1.0 : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .disabled(!hasContent)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(language.displayName), \(count) songs, \(isSelected ? "selected" : "not selected")")
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
