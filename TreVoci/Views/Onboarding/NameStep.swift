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
                .font(.nunito(.black, size: 26))
                .foregroundStyle(Color.bark)
                .multilineTextAlignment(.center)

            // Text field
            TextField("e.g. Sofia", text: $childName)
                .font(.nunito(.semiBold, size: 20))
                .foregroundStyle(Color.bark)
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
                .font(.nunito(.semiBold, size: 12))
                .foregroundStyle(Color.mist)

            Spacer()

            // Next button
            Button(action: onNext) {
                Text("Next")
                    .font(.nunito(.bold, size: 17))
                    .foregroundStyle(Color.bark)
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
