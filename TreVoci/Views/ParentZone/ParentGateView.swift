import SwiftUI

struct ParentGateView: View {
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var unlocked = false
    @State private var holdTask: Task<Void, Never>?

    let onUnlock: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Lock icon
                ZStack {
                    Circle()
                        .fill(Color.warm)
                        .frame(width: 90, height: 90)
                    Image(systemName: unlocked ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.bark)
                        .contentTransition(.symbolEffect(.replace))
                }

                Text("Parent Zone")
                    .font(.nunito(.black, size: 24))
                    .foregroundStyle(Color.bark)

                Text("Hold the button for 3 seconds")
                    .font(.nunito(.semiBold, size: 14))
                    .foregroundStyle(Color.stone)

                // Hold-to-unlock button
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.sand, lineWidth: 6)
                        .frame(width: 80, height: 80)

                    // Conic gradient progress
                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(
                            AngularGradient(
                                colors: [.coral, .rose, .gold, .coral],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.05), value: holdProgress)

                    // Inner circle
                    Circle()
                        .fill(isHolding ? Color.coral.opacity(0.15) : Color.warm)
                        .frame(width: 68, height: 68)

                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(isHolding ? Color.coral : Color.stone)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !unlocked else { return }
                            if !isHolding {
                                startHold()
                            }
                        }
                        .onEnded { _ in
                            if !unlocked {
                                cancelHold()
                            }
                        }
                )
                .accessibilityLabel("Hold for 3 seconds to unlock parent zone")
                .accessibilityAddTraits(.isButton)

                Spacer()

                // Back link
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Back to songs")
                            .font(.nunito(.semiBold, size: 14))
                    }
                    .foregroundStyle(Color.stone)
                }
                .accessibilityLabel("Back to songs")
                .accessibilityAddTraits(.isButton)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Hold Logic

    private func startHold() {
        isHolding = true
        holdProgress = 0
        holdTask?.cancel()
        holdTask = Task { @MainActor in
            // Advance the ring in 0.05s steps over 3 seconds.
            while holdProgress < 1.0 {
                try? await Task.sleep(nanoseconds: 50_000_000)
                if Task.isCancelled { return }
                holdProgress += 0.05 / 3.0
            }
            unlocked = true
            isHolding = false
            // Small delay for visual feedback
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            onUnlock()
        }
    }

    private func cancelHold() {
        holdTask?.cancel()
        holdTask = nil
        isHolding = false
        withAnimation(.easeOut(duration: 0.3)) {
            holdProgress = 0
        }
    }
}

#if DEBUG
#Preview {
    ParentGateView(onUnlock: {}, onBack: {})
}
#endif
