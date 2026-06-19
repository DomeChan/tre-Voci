import SwiftUI

struct SongCard: View {
    @Environment(\.horizontalSizeClass) private var hSize
    let song: Song
    let onTap: () -> Void

    private var cardWidth: CGFloat { hSize == .regular ? 220 : 160 }
    private var cardHeight: CGFloat { hSize == .regular ? 250 : 190 }
    private var emojiSize: CGFloat { hSize == .regular ? 46 : 36 }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Emoji
                Text(song.icon)
                    .font(.system(size: emojiSize))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                // English title
                Text(song.title(for: .en))
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                // Subtitles (IT + ZH if cross-cultural)
                if song.isCrossCultural {
                    HStack(spacing: 4) {
                        if let it = song.titles["it"] {
                            Text(it)
                                .lineLimit(1)
                        }
                        if song.titles["it"] != nil && song.titles["zh"] != nil {
                            Text("·")
                        }
                        if let zh = song.titles["zh"] {
                            Text(zh)
                                .lineLimit(1)
                        }
                    }
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                }

                // Duration
                Text(song.formattedDuration)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(16)
            .frame(width: cardWidth, height: cardHeight)
            .background(
                LinearGradient(
                    colors: song.backgroundGradient.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(Color.black.opacity(0.25))
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(song.title(for: .en)), \(song.formattedDuration)")
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    HStack {
        SongCard(song: .preview, onTap: {})
    }
    .padding()
}
#endif
