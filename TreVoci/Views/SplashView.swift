import SwiftUI

struct SplashView: View {
    @State private var animate = false
    let onStart: () -> Void

    var body: some View {
        ZStack {
            // Radial gradient background
            RadialGradient(
                colors: [
                    Color(hex: "FFF5EB"),
                    Color(hex: "FDE8D5"),
                    Color(hex: "E5D8F0")
                ],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Frosted glass music icon
                ZStack {
                    RoundedRectangle(cornerRadius: 36)
                        .fill(.ultraThinMaterial)
                        .frame(width: 110, height: 110)
                        .shadow(color: .black.opacity(0.06), radius: 20, y: 8)

                    Text("🎵")
                        .font(.system(size: 48))
                }

                // App title with gradient text
                Text("Tre Voci")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.coral, .rose, .gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Subtitle
                Text("THREE VOICES · ONE SONG")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.stone)
                    .tracking(2.5)

                // Animated flags
                HStack(spacing: 24) {
                    flagView("🇮🇹", delay: 0)
                    flagView("🇨🇳", delay: 0.3)
                    flagView("🇬🇧", delay: 0.6)
                }
                .padding(.top, 8)

                Spacer()

                // CTA Button
                Button(action: onStart) {
                    Text("Cominciamo! · 开始吧!")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.coral, .rose],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .coral.opacity(0.3), radius: 12, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .accessibilityLabel("Let's begin")
                .accessibilityAddTraits(.isButton)
            }
        }
        .onAppear { animate = true }
    }

    private func flagView(_ flag: String, delay: Double) -> some View {
        Text(flag)
            .font(.system(size: 40))
            .offset(y: animate ? -10 : 10)
            .scaleEffect(animate ? 1.1 : 0.9)
            .animation(
                .easeInOut(duration: 2.4)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: animate
            )
    }
}

#if DEBUG
#Preview {
    SplashView(onStart: {})
}
#endif
