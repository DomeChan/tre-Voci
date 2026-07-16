import SwiftUI

struct DailyMixCard: View {
    let songs: [Song]
    let duration: Int
    /// See SongCard's `glareCut` doc comment — same uniform-brightness-cut
    /// reasoning applied to this card's gradient. Tied to actual Bedtime Mode
    /// only, never to system Dark Mode alone.
    var glareCut: Bool = false
    let onPlay: () -> Void

    private var songCount: Int { songs.count }

    /// Distinct languages across the mix — data-driven, not a hardcoded "3".
    private var languageCount: Int {
        Set(songs.flatMap { $0.availableLanguages }).count
    }

    private var tracklistLabel: String {
        songs.map { $0.title(for: .en) }.joined(separator: ", ")
    }

    var body: some View {
        Button(action: onPlay) {
            ZStack {
                // Background gradient, scrimmed per DESIGN.md's Cards spec ("always
                // under a black @ 0.32 scrim for text legibility") — SongCard already
                // does this; this hero card had been missing it, leaving white text
                // on the coral region under ~3:1 contrast.
                LinearGradient(
                    colors: [.coral, .rose, .plum],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(Color.black.opacity(0.32))

                // Decorative circles
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 180)
                    .offset(x: -80, y: -60)

                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 120)
                    .offset(x: 100, y: 40)

                // Content
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎵 Daily Mix")
                        .font(.nunito(.bold, size: 13, relativeTo: .subheadline))
                        .foregroundStyle(.white.opacity(0.85))

                    Text("Today's Adventure")
                        .font(.nunito(.black, size: 28, relativeTo: .title))
                        .foregroundStyle(.white)

                    Text(songCount == 0
                         ? "No songs available yet"
                         : "\(songCount) \(songCount == 1 ? "Song" : "Songs") · \(languageCount) \(languageCount == 1 ? "Language" : "Languages") · ~\(max(1, duration / 60)) min")
                        .font(.nunito(.semiBold, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(.white.opacity(0.85))

                    // Tracklist preview — catalog glyphs for today's songs.
                    // VoiceOver reads the real song names below.
                    if !songs.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(songs) { song in
                                Text(song.icon)
                                    .font(.system(size: 18))
                                    .frame(width: 32, height: 32)
                                    .background(.white.opacity(0.18))
                                    .clipShape(Circle())
                            }
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Today's songs: \(tracklistLabel)")
                    }

                    HStack {
                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                            Text("Play Mix")
                                .font(.nunito(.bold, size: 16, relativeTo: .callout))
                        }
                        .foregroundStyle(Color.coralDeep)
                        .padding(.horizontal, 24)
                        .frame(minHeight: 44)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .coral.opacity(0.35), radius: 8, y: 4)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 200)
            // Same reasoning as SongCard: this hero's decorative circles are
            // point-positioned, so cap Dynamic Type to the standard range and let
            // minHeight (not a fixed height) absorb any remaining growth safely.
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: .coral.opacity(0.25), radius: 16, y: 8)
            .brightness(glareCut ? -0.22 : 0)
        }
        .buttonStyle(.plain)
        .disabled(songCount == 0)
        .opacity(songCount == 0 ? 0.55 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            songCount == 0
                ? "Daily mix has no songs available yet"
                : "Play daily mix: \(tracklistLabel), \(languageCount) languages"
        )
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    DailyMixCard(songs: [.preview, .preview, .preview], duration: 720, onPlay: {})
        .padding()
}
#endif
