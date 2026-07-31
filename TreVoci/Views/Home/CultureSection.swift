import SwiftUI

struct CultureSection: View {
    let title: String
    let language: Language
    let songs: [Song]
    var dimmed: Bool = false
    /// Screen-level chrome (the section header and "on the way" copy sit directly
    /// on Home's background) follows the display palette — Bedtime Mode OR
    /// system Dark Mode, either one. The song rows below carry their own
    /// self-contained light card background and don't need this.
    var usesDarkPalette: Bool = false
    /// The row brightness cut (see cultureRow) is a glare fix for an actually
    /// dark ROOM, not a system-appearance match — it must only follow real
    /// Bedtime Mode, never system Dark Mode alone. A parent using Dark Mode in
    /// daylight shouldn't get dimmed, lower-contrast song rows for no reason.
    var glareCut: Bool = false
    let onSongTap: (Song) -> Void

    /// Auto-fill columns by available width so the grid genuinely fills the canvas:
    /// 1 column on iPhone, more as the iPad widens (≈3 in portrait, ≈4 in landscape) —
    /// no fixed cap, no blank side gutters.
    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Match the cross-cultural section's header treatment: a real, visible
            // title (`title` already carries the flag, e.g. "🇮🇹 Filastrocche
            // Italiane") — previously only the bare flag rendered, with the
            // language name living solely in the accessibility label.
            Text(title)
                .font(.nunito(.black, size: 17, relativeTo: .headline))
                .foregroundStyle(usesDarkPalette ? Color.nightInk : Color.bark)
                .padding(.horizontal, 20)

            if songs.isEmpty {
                // Honest "on the way" state for a registered language we don't have
                // real recordings for yet — never a silent empty gap (P4, P10).
                // Shown at full opacity (it's informational) whether or not selected.
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .font(.system(size: 11))
                    Text("Songs in \(language.displayName) are on the way \u{2014} we only add real native recordings.")
                        .font(.nunito(.semiBold, size: 12, relativeTo: .footnote))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(usesDarkPalette ? Color.nightStone : Color.stone)
                .padding(.horizontal, 20)
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
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
                            .font(.nunito(.semiBold, size: 11, relativeTo: .caption2))
                    }
                    .foregroundStyle(usesDarkPalette ? Color.nightStone : Color.stone)
                    .padding(.horizontal, 20)
                }
            }
        }
        // The row brightness cut (glareCut, see cultureRow) stacks with this
        // opacity dim; raise the floor when it's active so the two effects
        // together don't drop dimmed text below the AAA-leaning bar.
        .opacity(songs.isEmpty ? 1.0 : (dimmed ? (glareCut ? 0.55 : 0.4) : 1.0))
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
                    .font(.nunito(.bold, size: 15, relativeTo: .subheadline))
                    .foregroundStyle(Color.bark)

                Text(song.formattedDuration)
                    .font(.nunito(.semiBold, size: 12, relativeTo: .caption))
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
        // Same uniform-brightness-cut reasoning as SongCard/DailyMixCard: these
        // pastel rows are self-contained and stay legible unchanged, but at full
        // luminance they glare against an actually dark bedtime room. Tied to
        // glareCut (real Bedtime Mode), never to system Dark Mode alone.
        .brightness(glareCut ? -0.22 : 0)
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
