import SwiftUI

struct ActivityBridgeView: View {
    @Environment(PersistenceService.self) private var persistence
    @State private var viewModel: SessionViewModel?
    @State private var wiggle = false

    let song: Song
    let onHome: () -> Void
    let onOneMore: () -> Void

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            if let vm = viewModel {
                switch vm.phase {
                case .activity:
                    activityPhase(vm: vm)
                        .transition(.opacity)
                case .summary:
                    summaryPhase(vm: vm)
                        .transition(.opacity)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel?.phase == .summary)
        .onAppear {
            if viewModel == nil {
                viewModel = SessionViewModel(song: song, persistence: persistence)
            }
            wiggle = true
        }
    }

    // MARK: - Activity Phase

    private func activityPhase(vm: SessionViewModel) -> some View {
        VStack(spacing: 24) {
            Spacer()

            // Wiggling activity emoji
            Text(song.activity.icon)
                .font(.system(size: 72))
                .rotationEffect(.degrees(wiggle ? 10 : -10))
                .animation(
                    .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                    value: wiggle
                )

            // Celebration header
            Text("Brava \(vm.childName)! \u{1F389}")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            Text("Time for a little activity!")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.stone)

            // Activity prompts card
            activityCard

            Spacer()

            // Done button
            Button(action: { vm.completeActivity() }) {
                Text("Done! \u{00B7} Fatto! \u{00B7} \u{505A}\u{5B8C}\u{4E86}!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .accessibilityLabel("Done with activity")
            .accessibilityAddTraits(.isButton)
            .padding(.horizontal, 24)

            // Skip link
            Button(action: { vm.skipActivity() }) {
                Text("Skip activity")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
            }
            .accessibilityLabel("Skip activity")
            .accessibilityAddTraits(.isButton)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Activity Card

    private var activityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Language.allCases) { lang in
                if let prompt = song.activity.prompts[lang.rawValue], !prompt.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        Text(lang.flag)
                            .font(.system(size: 20))
                        Text(prompt)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.bark)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
        .padding(.horizontal, 24)
    }

    // MARK: - Summary Phase

    private func summaryPhase(vm: SessionViewModel) -> some View {
        VStack(spacing: 24) {
            Spacer()

            // Green checkmark
            ZStack {
                Circle()
                    .fill(Color.italianGreen.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.italianGreen)
            }
            .scaleEffect(vm.showConfetti ? 1.0 : 0.5)
            .opacity(vm.showConfetti ? 1.0 : 0.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: vm.showConfetti)

            Text("Session Complete!")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            Text(vm.sessionSummaryText)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.stone)

            // Language badges
            HStack(spacing: 12) {
                ForEach(vm.languagesHeard) { lang in
                    HStack(spacing: 4) {
                        Text(lang.flag)
                            .font(.system(size: 16))
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(lang.primaryColor)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(lang.backgroundColor)
                    .clipShape(Capsule())
                }
            }

            Spacer()

            // Back Home button
            Button(action: onHome) {
                Text("Back Home")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .accessibilityLabel("Back to home screen")
            .accessibilityAddTraits(.isButton)
            .padding(.horizontal, 24)

            // One More Song button
            Button(action: onOneMore) {
                Text("One More Song")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.coral)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.coral.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Play one more song")
            .accessibilityAddTraits(.isButton)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

#if DEBUG
#Preview {
    ActivityBridgeView(
        song: .preview,
        onHome: {},
        onOneMore: {}
    )
    .environment(PersistenceService())
}
#endif
