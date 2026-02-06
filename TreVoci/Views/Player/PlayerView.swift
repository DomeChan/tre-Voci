import SwiftUI

struct PlayerView: View {
    @State private var viewModel: PlayerViewModel
    @State private var breathe = false
    let onBack: () -> Void
    let onActivityBridge: (Song) -> Void

    init(song: Song, onBack: @escaping () -> Void, onActivityBridge: @escaping (Song) -> Void) {
        self._viewModel = State(initialValue: PlayerViewModel(song: song))
        self.onBack = onBack
        self.onActivityBridge = onActivityBridge
    }

    var body: some View {
        ZStack {
            // Background gradient from song data
            LinearGradient(
                colors: viewModel.song.backgroundGradient.map { Color(hex: $0) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(Color.black.opacity(0.15))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer()

                // Song emoji with breathing animation
                Text(viewModel.song.icon)
                    .font(.system(size: 80))
                    .scaleEffect(breathe ? 1.08 : 1.0)
                    .animation(
                        viewModel.isPlaying
                            ? .easeInOut(duration: 2.5).repeatForever(autoreverses: true)
                            : .easeOut(duration: 0.3),
                        value: breathe
                    )
                    .accessibilityHidden(true)

                // Title
                Text(viewModel.currentTitle)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 12)
                    .animation(.easeOut(duration: 0.3), value: viewModel.currentLanguage)

                // Melody origin subtitle
                Text(viewModel.song.melodyOrigin)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.top, 4)

                Spacer()

                // Lyrics
                LyricsView(
                    text: viewModel.currentLyricText,
                    language: viewModel.currentLanguage
                )
                .padding(.horizontal, 32)

                Spacer()

                // Language picker
                if viewModel.song.isCrossCultural {
                    LanguagePicker(
                        languages: viewModel.availableLanguages,
                        activeLanguage: viewModel.currentLanguage,
                        onSelect: { viewModel.switchLanguage($0) }
                    )
                    .padding(.bottom, 20)
                }

                // Progress bar
                ProgressBar(
                    progress: viewModel.progress,
                    segmentCount: viewModel.segmentCount,
                    currentSegment: viewModel.currentSegment
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

                // Playback controls
                playbackControls
                    .padding(.bottom, 32)
            }

            // Language switch toast
            if viewModel.showLanguageToast {
                languageToast
                    .transition(.opacity.combined(with: .offset(y: -10)))
            }
        }
        .onAppear {
            viewModel.play()
            breathe = true
        }
        .onDisappear {
            viewModel.pause()
        }
        // Poll for progress updates
        .onReceive(
            Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        ) { _ in
            viewModel.updateState()
            // Check if playback finished → go to activity
            if !viewModel.isPlaying && viewModel.progress >= 0.99 {
                onActivityBridge(viewModel.song)
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: {
                viewModel.pause()
                onBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Back to home")
            .accessibilityAddTraits(.isButton)

            Spacer()

            // AirPlay indicator
            HStack(spacing: 4) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 10))
                Text("iPhone")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: 40) {
            // Restart
            Button(action: { viewModel.restart() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Restart")
            .accessibilityAddTraits(.isButton)

            // Play/Pause
            Button(action: { viewModel.togglePlayPause() }) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
            .accessibilityAddTraits(.isButton)

            // Skip to activity
            Button(action: {
                viewModel.skipToActivity()
                onActivityBridge(viewModel.song)
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Skip to activity")
            .accessibilityAddTraits(.isButton)
        }
    }

    // MARK: - Language Toast

    private var languageToast: some View {
        VStack {
            HStack(spacing: 6) {
                Text(viewModel.toastLanguage.flag)
                Text("Now playing in \(viewModel.toastLanguage.displayName)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.top, 60)

            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    PlayerView(
        song: .preview,
        onBack: {},
        onActivityBridge: { _ in }
    )
}
#endif
