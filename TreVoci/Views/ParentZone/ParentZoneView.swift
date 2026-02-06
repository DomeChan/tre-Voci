import SwiftUI

struct ParentZoneView: View {
    @Environment(PersistenceService.self) private var persistence
    let onBack: () -> Void
    let onReset: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Exposure chart
                ExposureChart(weeklySeconds: persistence.state.weeklyListeningSeconds)
                    .padding(.horizontal, 20)

                // Research tip
                researchCard
                    .padding(.horizontal, 20)

                // Settings
                SettingsView(onReset: onReset)
                    .padding(.horizontal, 20)

                Color.clear.frame(height: 32)
            }
        }
        .background(Color.cream)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Home")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color.coral)
            }
            .accessibilityLabel("Back to home")
            .accessibilityAddTraits(.isButton)

            Spacer()

            Text("Parent Zone")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            Spacer()

            // Invisible spacer to center title
            Color.clear.frame(width: 60, height: 1)
        }
    }

    // MARK: - Research Card

    private var researchCard: some View {
        let tips = [
            "Each language needs ~25% of waking input for active production (Montanari, 2013).",
            "Children can distinguish 3+ languages by 8 months. Consistent daily exposure is key.",
            "Singing activates both language and music brain centers, boosting retention by 40%.",
            "Bilingual children show enhanced executive function by age 3 (Bialystok, 2011).",
        ]
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let tipIndex = (dayIndex - 1) % tips.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.englishBlue)
                Text("Research Corner")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
            }
            Text(tips[tipIndex])
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.stone)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
    }
}

#if DEBUG
#Preview {
    ParentZoneView(onBack: {}, onReset: {})
        .environment(PersistenceService())
}
#endif
