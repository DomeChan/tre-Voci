import SwiftUI

struct OnboardingContainer: View {
    @Environment(PersistenceService.self) private var persistence
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentStep = 0
    @State private var childName = ""
    @State private var selectedLanguages: Set<Language> = Set(Language.all)
    let onComplete: () -> Void

    private let totalSteps = 3

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

                    SpeakerStep(onFinish: completeOnboarding)
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
