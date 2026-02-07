import SwiftUI

struct CultureSection: View {
    let title: String
    let language: Language
    let songs: [Song]
    var dimmed: Bool = false
    let onSongTap: (Song) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(songs) { song in
                    Button {
                        onSongTap(song)
                    } label: {
                        cultureRow(song: song)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(song.title(for: language)), \(song.formattedDuration)")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(.horizontal, 20)

            if dimmed {
                HStack(spacing: 4) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 10))
                    Text("Not in your selection")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color.stone)
                .padding(.horizontal, 20)
            }
        }
        .opacity(dimmed ? 0.4 : 1.0)
    }

    private func cultureRow(song: Song) -> some View {
        HStack(spacing: 12) {
            Text(song.icon)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(language.backgroundColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title(for: language))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bark)

                Text(song.formattedDuration)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(language.primaryColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(language.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 20) {
        CultureSection(
            title: "\u{1F1EE}\u{1F1F9} Filastrocche Italiane",
            language: .it,
            songs: [.preview],
            onSongTap: { _ in }
        )
        CultureSection(
            title: "\u{1F1EC}\u{1F1E7} English Nursery Rhymes",
            language: .en,
            songs: [.preview],
            dimmed: true,
            onSongTap: { _ in }
        )
    }
}
#endif
