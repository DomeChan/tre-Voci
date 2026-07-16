import SwiftUI

struct SongCard: View {
    @Environment(\.horizontalSizeClass) private var hSize
    let song: Song
    /// This card's gradient is self-contained and stays legible unchanged under
    /// system Dark Mode — except at full luminance it glares in an actually dark
    /// bedtime room. A uniform brightness cut (not a re-theme) keeps every
    /// internal contrast pair intact while cutting the real glare. Tied to
    /// actual Bedtime Mode only, never to system Dark Mode alone — a parent
    /// using Dark Mode in daylight shouldn't get dimmed cards for no reason.
    var glareCut: Bool = false
    let onTap: () -> Void

    private var cardWidth: CGFloat { hSize == .regular ? 220 : 160 }
    private var cardHeight: CGFloat { hSize == .regular ? 250 : 190 }
    private var emojiSize: CGFloat { hSize == .regular ? 46 : 36 }

    /// DESIGN.md's Colored Glow Rule: shadows are never neutral — every shadow
    /// inherits the hue of the surface casting it. Each card's own gradient
    /// supplies that hue instead of a fixed accent.
    private var glowColor: Color {
        guard let first = song.backgroundGradient.first else { return .coral }
        return Color(hex: first)
    }

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
                    .font(.nunito(.extraBold, size: 15, relativeTo: .subheadline))
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
                    .font(.nunito(.semiBold, size: 11, relativeTo: .caption2))
                    .foregroundStyle(.white.opacity(0.95))
                }

                // Duration
                Text(song.formattedDuration)
                    .font(.nunito(.bold, size: 11, relativeTo: .caption2))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(16)
            .frame(width: cardWidth, height: cardHeight)
            // These tiles are fixed-size scroller cards, not free-flowing text — cap
            // Dynamic Type to the standard range so accessibility sizes don't blow out
            // the fixed frame. The reading-focused Home title/section headers above
            // are not capped and scale all the way.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .background(
                LinearGradient(
                    colors: song.backgroundGradient.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(Color.black.opacity(0.32))
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: glowColor.opacity(0.25), radius: 16, y: 8)
            .brightness(glareCut ? -0.22 : 0)
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
