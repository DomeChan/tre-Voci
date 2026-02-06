import SwiftUI

struct NameStep: View {
    @Binding var childName: String
    let onNext: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Text("👶")
                .font(.system(size: 56))

            // Title
            Text("What's your little one's name?")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)
                .multilineTextAlignment(.center)

            // Text field
            TextField("e.g. Sofia", text: $childName)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.warm)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 40)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit { onNext() }

            // Privacy note
            Text("Never sent anywhere. Stored only on this device.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.mist)

            Spacer()

            // Next button
            Button(action: onNext) {
                Text("Next")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
            .accessibilityLabel("Next step")
            .accessibilityAddTraits(.isButton)
        }
        .onAppear { isFocused = true }
    }
}

#if DEBUG
#Preview {
    NameStep(childName: .constant(""), onNext: {})
}
#endif
