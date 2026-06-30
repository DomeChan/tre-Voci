import SwiftUI

struct OnboardingContainer: View {
    @Environment(PersistenceService.self) private var persistence
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentStep = 0
    @State private var childName = ""
    @State private var selectedLanguages: Set<Language> = OnboardingContainer.defaultSelection()
    let onComplete: () -> Void

    private let totalSteps = 3

    /// A sensible starting selection for *any* family: the device-locale language
    /// (if we support it) plus English as a common second, topped up to the
    /// 2-language minimum. Only ever picks languages that actually have content —
    /// a "coming soon" registered language is never auto-selected. No hardcoded trio.
    static func defaultSelection() -> Set<Language> {
        let catalog = SongCatalogService()
        let withContent = Language.all.filter { lang in
            catalog.allSongs.contains { $0.audioFiles[lang.code] != nil }
        }
        let pool = withContent.isEmpty ? Language.all : withContent

        var picks: [Language] = []
        if let code = Locale.current.language.languageCode?.identifier,
           let match = pool.first(where: { $0.code == code }) {
            picks.append(match)
        }
        if let english = pool.first(where: { $0.code == "en" }), !picks.contains(english) {
            picks.append(english)
        }
        for lang in pool where picks.count < 2 {
            if !picks.contains(lang) { picks.append(lang) }
        }
        return Set(picks)
    }

    private var orderedSelection: [Language] {
        Language.all.filter { selectedLanguages.contains($0) }
    }

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Step dots
                stepDots
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // Step content
                TabView(selection: $currentStep) {
                    NameStep(childName: $childName, onNext: advanceStep)
                        .tag(0)

                    LanguageStep(selectedLanguages: $selectedLanguages, onNext: advanceStep)
                        .tag(1)

                    SpeakerStep(selectedLanguages: orderedSelection, onFinish: completeOnboarding)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
            .readableContentWidth()
        }
    }

    // MARK: - Step Dots

    private var stepDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Color.coral : Color.sand)
                    .frame(width: index == currentStep ? 28 : 8, height: 8)
                    .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
    }

    // MARK: - Actions

    private func advanceStep() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    private func completeOnboarding() {
        persistence.update { state in
            state.childName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
            state.selectedLanguages = Language.all.filter { selectedLanguages.contains($0) }.map(\.rawValue)
            state.hasCompletedOnboarding = true
        }
        onComplete()
    }
}

#if DEBUG
#Preview {
    OnboardingContainer(onComplete: {})
        .environment(PersistenceService())
}
#endif
