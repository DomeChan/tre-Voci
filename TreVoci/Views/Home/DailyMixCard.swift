import SwiftUI

struct DailyMixCard: View {
    let songs: [Song]
    let duration: Int
    let onPlay: () -> Void

    private var songCount: Int { songs.count }

    private var tracklistLabel: String {
        songs.map { $0.title(for: .en) }.joined(separator: ", ")
    }

    var body: some View {
        Button(action: onPlay) {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.coral, .rose, .plum],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

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
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .textCase(.uppercase)
                        .tracking(1.5)

                    Text("Today's\nAdventure")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(songCount) Songs · 3 Languages · ~\(duration / 60) min")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
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
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.coral)
                        .padding(.horizontal, 24)
                        .frame(minHeight: 44)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: .coral.opacity(0.25), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Play daily mix, \(songCount) songs in 3 languages")
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    DailyMixCard(songs: [.preview, .preview, .preview], duration: 720, onPlay: {})
        .padding()
}
#endif
