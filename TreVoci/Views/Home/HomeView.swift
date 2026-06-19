import SwiftUI
import AVFoundation

enum SheetDestination: Identifiable {
    case player(Song)
    case activity(Song, Int) // song + actual elapsed seconds
    case parentGate
    case parentZone

    var id: String {
        switch self {
        case .player(let song): return "player-\(song.id)"
        case .activity(let song, _): return "activity-\(song.id)"
        case .parentGate: return "parentGate"
        case .parentZone: return "parentZone"
        }
    }
}

struct HomeView: View {
    @Environment(PersistenceService.self) private var persistence
    @State private var viewModel: HomeViewModel?
    @State private var activeSheet: SheetDestination?
    @State private var routeMonitor = AudioRouteMonitor()

    private let catalog = SongCatalogService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Speaker pill
                speakerPill
                    .padding(.horizontal, 20)

                // Daily Mix Hero Card
                if let vm = viewModel {
                    DailyMixCard(
                        songs: vm.dailyMix,
                        duration: vm.dailyMixDuration,
                        onPlay: { playDailyMix() }
                    )
                    .padding(.horizontal, 20)
                }

                // Cross-Cultural Section
                crossCulturalSection

                // Italian Section
                if let vm = viewModel {
                    CultureSection(
                        title: "\u{1F1EE}\u{1F1F9} Filastrocche Italiane",
                        language: .it,
                        songs: vm.italianSongs,
                        dimmed: !persistence.state.isLanguageSelected(.it),
                        onSongTap: { selectSong($0) }
                    )
                }

                // Chinese Section
                if let vm = viewModel {
                    CultureSection(
                        title: "\u{1F1E8}\u{1F1F3} \u{4E2D}\u{6587}\u{513F}\u{6B4C}",
                        language: .zh,
                        songs: vm.chineseSongs,
                        dimmed: !persistence.state.isLanguageSelected(.zh),
                        onSongTap: { selectSong($0) }
                    )
                }

                // English Section
                if let vm = viewModel {
                    CultureSection(
                        title: "\u{1F1EC}\u{1F1E7} English Nursery Rhymes",
                        language: .en,
                        songs: vm.englishSongs,
                        dimmed: !persistence.state.isLanguageSelected(.en),
                        onSongTap: { selectSong($0) }
                    )
                }

                // Bottom padding
                Color.clear.frame(height: 32)
            }
        }
        .background(Color.cream)
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .player(let song):
                PlayerView(
                    song: song,
                    selectedLanguages: persistence.state.selectedLanguages.compactMap { Language(rawValue: $0) },
                    bedtime: persistence.state.bedtimeMode,
                    onBack: { activeSheet = nil },
                    onActivityBridge: { song, elapsed in
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeSheet = .activity(song, elapsed)
                        }
                    }
                )
            case .activity(let song, let elapsed):
                ActivityBridgeView(
                    song: song,
                    actualDurationSeconds: elapsed,
                    selectedLanguages: persistence.state.selectedLanguages.compactMap { Language(rawValue: $0) },
                    onHome: {
                        activeSheet = nil
                    },
                    onOneMore: {
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let vm = viewModel,
                               let next = vm.crossCulturalSongs.first(where: { $0.id != song.id }) {
                                activeSheet = .player(next)
                            }
                        }
                    }
                )
                .environment(persistence)
            case .parentGate:
                ParentGateView(
                    onUnlock: {
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeSheet = .parentZone
                        }
                    },
                    onBack: { activeSheet = nil }
                )
            case .parentZone:
                ParentZoneView(
                    onBack: { activeSheet = nil },
                    onReset: {
                        activeSheet = nil
                        persistence.resetAll()
                    }
                )
                .environment(persistence)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(catalog: catalog, persistence: persistence)
            }
            routeMonitor.start()
        }
        .onDisappear {
            routeMonitor.stop()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)

                Text("\(persistence.state.displayName)'s Songs")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
            }

            Spacer()

            // Parent zone button
            Button(action: { activeSheet = .parentGate }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.mist)
            }
            .accessibilityLabel("Parent zone")
            .accessibilityAddTraits(.isButton)
        }
    }

    // MARK: - Speaker Pill

    private var speakerPill: some View {
        ZStack {
            HStack(spacing: 6) {
                Image(systemName: routeMonitor.iconName)
                    .font(.system(size: 10))
                Text(routeMonitor.routeName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Color.stone)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.warm)
            .clipShape(Capsule())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: routeMonitor.routeName)

            AirPlayPickerButton()
                .frame(width: 120, height: 28)
                .opacity(0.015)
        }
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Playing on \(routeMonitor.routeName). Tap to choose audio output.")
    }

    // MARK: - Cross-Cultural Section

    private var crossCulturalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\u{1F30D} Same Song, Three Worlds")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let vm = viewModel {
                        ForEach(vm.crossCulturalSongs) { song in
                            SongCard(song: song) {
                                selectSong(song)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Greeting

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Buongiorno \u{2600}\u{FE0F}"
        case 12..<17: return "Buon pomeriggio \u{1F324}\u{FE0F}"
        case 17..<21: return "Buonasera \u{1F305}"
        default: return "Buonanotte \u{1F319}"
        }
    }

    // MARK: - Actions

    private func selectSong(_ song: Song) {
        activeSheet = .player(song)
    }

    private func playDailyMix() {
        guard let vm = viewModel, let first = vm.dailyMix.first else { return }
        selectSong(first)
    }
}

// MARK: - Audio Route Monitor

/// Reads the live audio output route from `AVAudioSession` so the speaker pill
/// tells the truth (AirPlay device, Bluetooth, headphones, or this iPhone)
/// instead of a hardcoded "iPhone Speaker" label.
@Observable
@MainActor
final class AudioRouteMonitor {
    private(set) var routeName: String = "iPhone Speaker"
    private(set) var iconName: String = "speaker.wave.2.fill"

    private var observer: NSObjectProtocol?

    func start() {
        updateRoute()
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateRoute()
            }
        }
    }

    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
    }

    private func updateRoute() {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        guard let output = outputs.first else {
            routeName = "iPhone Speaker"
            iconName = "speaker.wave.2.fill"
            return
        }

        switch output.portType {
        case .airPlay:
            routeName = output.portName
            iconName = "airplayaudio"
        case .bluetoothA2DP, .bluetoothLE, .bluetoothHFP:
            routeName = output.portName
            iconName = "hifispeaker.fill"
        case .headphones, .headsetMic:
            routeName = "Headphones"
            iconName = "headphones"
        case .builtInSpeaker:
            routeName = "iPhone Speaker"
            iconName = "speaker.wave.2.fill"
        default:
            routeName = output.portName
            iconName = "speaker.wave.2.fill"
        }
    }
}

#if DEBUG
#Preview {
    HomeView()
        .environment(PersistenceService())
}
#endif
