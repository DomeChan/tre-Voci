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
                    .font(.nunito(.black, size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.coral, .rose, .gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Subtitle
                Text("THREE VOICES · ONE SONG")
                    .font(.nunito(.bold, size: 12))
                    .foregroundStyle(Color.stone)
                    .tracking(2.5)

                // Animated flags — one per registered language (Languages.json),
                // so a newly added language shows up here with no code change.
                // Sized down once the registry grows past the original trio, so
                // all of them stay on one row instead of clipping off-screen.
                HStack(spacing: flagSpacing) {
                    ForEach(Array(Language.all.enumerated()), id: \.element.id) { index, language in
                        flagView(language.flag, delay: Double(index % 4) * 0.2)
                    }
                }
                .padding(.top, 8)

                Spacer()

                // CTA Button
                Button(action: onStart) {
                    Text("Cominciamo! · 开始吧!")
                        .font(.nunito(.bold, size: 17))
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

    /// Shrinks once the registry outgrows the original three, so the row
    /// stays on one line instead of running off-screen.
    private var flagSpacing: CGFloat { Language.all.count > 3 ? 14 : 24 }
    private var flagFontSize: CGFloat { Language.all.count > 3 ? 30 : 40 }

    private func flagView(_ flag: String, delay: Double) -> some View {
        Text(flag)
            .font(.system(size: flagFontSize))
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
