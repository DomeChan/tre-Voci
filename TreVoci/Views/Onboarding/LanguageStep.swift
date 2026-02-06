import SwiftUI

struct LanguageStep: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            Text("Your family speaks")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            Text("Three beautiful languages!")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.stone)

            // Language rows
            VStack(spacing: 12) {
                languageRow(
                    icon: "🧔",
                    role: "Papà speaks",
                    flag: "🇮🇹",
                    language: "Italiano",
                    backgroundColor: .italianBg,
                    checkColor: .italianGreen
                )

                languageRow(
                    icon: "👩",
                    role: "Māmā speaks",
                    flag: "🇨🇳",
                    language: "中文",
                    backgroundColor: .chineseBg,
                    checkColor: .chineseRed
                )

                languageRow(
                    icon: "🏫",
                    role: "School & together",
                    flag: "🇬🇧",
                    language: "English",
                    backgroundColor: .englishBg,
                    checkColor: .englishBlue
                )
            }
            .padding(.horizontal, 24)

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
    }

    private func languageRow(
        icon: String,
        role: String,
        flag: String,
        language: String,
        backgroundColor: Color,
        checkColor: Color
    ) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text(role)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.stone)

                HStack(spacing: 6) {
                    Text(flag)
                        .font(.system(size: 18))
                    Text(language)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.bark)
                }
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(checkColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    LanguageStep(onNext: {})
}
#endif
