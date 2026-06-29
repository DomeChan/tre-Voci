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
                    .font(.nunito(.extraBold, size: 15))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
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
                    .font(.nunito(.semiBold, size: 11))
                    .foregroundStyle(.white.opacity(0.9))
                }

                // Duration
                Text(song.formattedDuration)
                    .font(.nunito(.bold, size: 11))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(16)
            .frame(width: cardWidth, height: cardHeight)
            .background(
                LinearGradient(
                    colors: song.backgroundGradient.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(Color.black.opacity(0.32))
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
