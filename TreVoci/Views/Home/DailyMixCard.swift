import SwiftUI

struct DailyMixCard: View {
    let songCount: Int
    let duration: Int
    let onPlay: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.coral, .rose, Color(hex: "9B59B6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative circles
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 180)
                .offset(x: -80, y: -60)

            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 120)
                .offset(x: 100, y: 40)

            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text("🎵 Daily Mix")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(1.5)

                Text("Today's\nAdventure")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(songCount) Songs · 3 Languages · ~\(duration / 60) min")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))

                HStack {
                    Spacer()

                    Button(action: onPlay) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14))
                            Text("Play Mix")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.coral)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    }
                    .accessibilityLabel("Play daily mix, \(songCount) songs in 3 languages")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .coral.opacity(0.25), radius: 16, y: 8)
    }
}

#if DEBUG
#Preview {
    DailyMixCard(songCount: 3, duration: 720, onPlay: {})
        .padding()
}
#endif
