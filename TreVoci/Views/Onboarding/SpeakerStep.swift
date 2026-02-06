import AVKit
import SwiftUI

struct SpeakerStep: View {
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Text("🔊")
                .font(.system(size: 56))

            // Title
            Text("Where should we play?")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)
                .multilineTextAlignment(.center)

            Text("Pick a speaker — you can change anytime")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.stone)

            // Speaker options
            VStack(spacing: 12) {
                // AirPlay picker
                HStack(spacing: 12) {
                    Text("📡")
                        .font(.system(size: 28))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AirPlay Speakers")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.bark)
                        Text("Sonos, HomePod, etc.")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.stone)
                    }

                    Spacer()

                    AirPlayButton()
                        .frame(width: 44, height: 44)
                        .accessibilityLabel("Select AirPlay speaker")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.warm)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // iPhone speaker
                HStack(spacing: 12) {
                    Text("📱")
                        .font(.system(size: 28))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("This iPhone")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.bark)
                        Text("Built-in speaker")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.stone)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.coral)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.warm)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("This iPhone, built-in speaker, selected")
            }
            .padding(.horizontal, 24)

            Spacer()

            // Finish button
            Button(action: onFinish) {
                Text("Pronti! · 准备好了!")
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
            .padding(.bottom, 32)
            .accessibilityLabel("We're ready, finish setup")
            .accessibilityAddTraits(.isButton)
        }
    }
}

// MARK: - AirPlay Route Picker

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.activeTintColor = UIColor(Color.coral)
        picker.prioritizesVideoDevices = false
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

#if DEBUG
#Preview {
    SpeakerStep(onFinish: {})
}
#endif
