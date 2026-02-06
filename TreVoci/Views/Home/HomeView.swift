import SwiftUI

enum SheetDestination: Identifiable {
    case player(Song)
    case activity(Song)
    case parentGate
    case parentZone

    var id: String {
        switch self {
        case .player(let song): return "player-\(song.id)"
        case .activity(let song): return "activity-\(song.id)"
        case .parentGate: return "parentGate"
        case .parentZone: return "parentZone"
        }
    }
}

struct HomeView: View {
    @Environment(PersistenceService.self) private var persistence
    @State private var viewModel: HomeViewModel?
    @State private var activeSheet: SheetDestination?

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
                        songCount: vm.dailyMix.count,
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
                        title: "🇮🇹 Filastrocche Italiane",
                        language: .it,
                        songs: vm.italianSongs,
                        onSongTap: { selectSong($0) }
                    )
                }

                // Chinese Section
                if let vm = viewModel {
                    CultureSection(
                        title: "🇨🇳 中文儿歌",
                        language: .zh,
                        songs: vm.chineseSongs,
                        onSongTap: { selectSong($0) }
                    )
                }

                // English Section
                if let vm = viewModel {
                    CultureSection(
                        title: "🇬🇧 English Nursery Rhymes",
                        language: .en,
                        songs: vm.englishSongs,
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
                    onBack: { activeSheet = nil },
                    onActivityBridge: { song in
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            activeSheet = .activity(song)
                        }
                    }
                )
            case .activity(let song):
                ActivityBridgeView(
                    song: song,
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
        HStack(spacing: 6) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 10))
            Text("iPhone Speaker")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(Color.stone)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.warm)
        .clipShape(Capsule())
    }

    // MARK: - Cross-Cultural Section

    private var crossCulturalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🌍 Same Song, Three Worlds")
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
        case 5..<12: return "Buongiorno ☀️"
        case 12..<17: return "Buon pomeriggio 🌤️"
        case 17..<21: return "Buonasera 🌅"
        default: return "Buonanotte 🌙"
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

#if DEBUG
#Preview {
    HomeView()
        .environment(PersistenceService())
}
#endif
