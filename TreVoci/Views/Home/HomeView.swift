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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: HomeViewModel?
    @State private var activeSheet: SheetDestination?
    @State private var routeMonitor = AudioRouteMonitor()

    private let catalog = SongCatalogService()

    /// Gap between dismissing one fullScreenCover and presenting the next, so the
    /// two transitions don't collide. Covers the system dismiss animation
    /// (~300ms); tightened from a prior 0.5s per product-register motion
    /// guidance (150-300ms band).
    private let sheetTransitionDelay: TimeInterval = 0.35

    /// The explicit, parent-controlled setting — narrows the Daily Mix to calm
    /// songs, lengthens language hand-off pauses, softens the fade-out. This is
    /// a deliberate playback-behavior choice and must NOT be inferred from the
    /// system appearance; a parent in system Dark Mode on a bright afternoon
    /// shouldn't silently get calm-only songs.
    private var isBedtime: Bool { persistence.state.bedtimeMode }

    /// Home stays cream/bright by default, but bedtime is this product's stated
    /// real-world context — a tired parent glancing at the screen in a dark room.
    /// Forcing full brightness there fights the product's own calm promise, so
    /// the screen-level chrome (not the self-contained song/card surfaces) swaps
    /// to the night palette when Bedtime Mode is on — OR when the system is
    /// already in Dark Mode, so Home doesn't silently override an OS-level
    /// accessibility/appearance choice the parent already made. This only
    /// affects the visual palette, not playback behavior (see `isBedtime`).
    private var usesDarkPalette: Bool { isBedtime || colorScheme == .dark }

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
                        glareCut: isBedtime,
                        onPlay: { playDailyMix() }
                    )
                    .padding(.horizontal, 20)
                }

                // Cross-Cultural Section
                crossCulturalSection

                // One culture section per registered language — data-driven, so a
                // new language in Languages.json appears here with no code change.
                if let vm = viewModel {
                    ForEach(Language.all) { lang in
                        CultureSection(
                            title: lang.sectionTitle,
                            language: lang,
                            songs: vm.songs(for: lang),
                            dimmed: !persistence.state.isLanguageSelected(lang),
                            usesDarkPalette: usesDarkPalette,
                            glareCut: isBedtime,
                            onSongTap: { selectSong($0) }
                        )
                    }
                }

                // Bottom padding
                Color.clear.frame(height: 32)
            }
            .readableContentWidth()
        }
        .background(usesDarkPalette ? Color.nightBg : Color.cream)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: usesDarkPalette)
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + sheetTransitionDelay) {
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + sheetTransitionDelay) {
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + sheetTransitionDelay) {
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
            autoArmBedtimeIfNeeded()
        }
        .onDisappear {
            routeMonitor.stop()
        }
    }

    /// Follows the same night window as the greeting (21:00–5:00). Only acts
    /// while the parent has never explicitly touched the Settings toggle —
    /// once they do, their choice sticks and auto-arm stops overriding it.
    private func autoArmBedtimeIfNeeded() {
        guard !persistence.state.bedtimeModeManuallySet else { return }
        let hour = Calendar.current.component(.hour, from: Date())
        let isNight = !(5..<21).contains(hour)
        if persistence.state.bedtimeMode != isNight {
            persistence.update { $0.bedtimeMode = isNight }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.nunito(.semiBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(usesDarkPalette ? Color.nightStone : Color.stone)

                Text("\(persistence.state.displayName)'s Songs")
                    .font(.nunito(.black, size: 26, relativeTo: .title))
                    .foregroundStyle(usesDarkPalette ? Color.nightInk : Color.bark)
            }

            Spacer()

            // Parent zone button
            Button(action: { activeSheet = .parentGate }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(usesDarkPalette ? Color.nightStone : Color.stone)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Parent zone")
            .accessibilityAddTraits(.isButton)
        }
    }

    // MARK: - Speaker Pill

    private var speakerPill: some View {
        ZStack {
            HStack(spacing: 7) {
                Image(systemName: routeMonitor.iconName)
                    .font(.system(size: 12))
                Text(routeMonitor.routeName)
                    .font(.nunito(.semiBold, size: 13, relativeTo: .caption))
                // Visual cue that this pill is switchable, not just a status
                // caption — the tap target itself is the invisible AirPlayPickerButton
                // layered underneath. Sized up and the pill given a hairline border
                // so it reads as a control, not a quiet label — the one affordance
                // that fulfills this product's actual job (get sound to the room).
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(usesDarkPalette ? Color.nightStone : Color.stone)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(usesDarkPalette ? Color.nightSurface : Color.warm)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder((usesDarkPalette ? Color.nightStone : Color.stone).opacity(0.25), lineWidth: 1)
            )
            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: routeMonitor.routeName)

            AirPlayPickerButton()
                .frame(width: 140, height: 44)
                .opacity(0.015)
        }
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Playing on \(routeMonitor.routeName). Tap to choose audio output.")
    }

    // MARK: - Cross-Cultural Section

    private var crossCulturalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\u{1F30D} Same Song, Many Worlds")
                .font(.nunito(.black, size: 17, relativeTo: .headline))
                .foregroundStyle(usesDarkPalette ? Color.nightInk : Color.bark)
                .padding(.horizontal, 20)

            if let vm = viewModel, vm.crossCulturalSongs.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .font(.system(size: 11))
                    Text("Cross-cultural songs are on the way \u{2014} we're still pairing melodies across languages.")
                        .font(.nunito(.semiBold, size: 12, relativeTo: .footnote))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(usesDarkPalette ? Color.nightStone : Color.stone)
                .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if let vm = viewModel {
                            ForEach(vm.crossCulturalSongs) { song in
                                SongCard(song: song, glareCut: isBedtime) {
                                    selectSong(song)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Greeting

    /// Rotates the greeting's language across the family's selected voices
    /// (Italian/Mandarin/English) by day, so no single language is quietly
    /// privileged as "the" greeting language. Stable for the whole day, not
    /// re-randomized on every Home visit.
    private var greetingLanguage: Language {
        let selected = persistence.state.selectedLanguages
            .compactMap { Language(rawValue: $0) }
            .filter { [.it, .zh, .en].contains($0) }
        guard !selected.isEmpty else { return .it }
        let dayOrdinal = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return selected[dayOrdinal % selected.count]
    }

    private var greeting: String {
        greetingText(language: greetingLanguage, hour: Calendar.current.component(.hour, from: Date()))
    }

    private func greetingText(language: Language, hour: Int) -> String {
        let band: Int
        switch hour {
        case 5..<12: band = 0
        case 12..<17: band = 1
        case 17..<21: band = 2
        default: band = 3
        }
        switch language {
        case .zh:
            return ["\u{65E9}\u{4E0A}\u{597D} \u{2600}\u{FE0F}", "\u{4E0B}\u{5348}\u{597D} \u{1F324}\u{FE0F}", "\u{665A}\u{4E0A}\u{597D} \u{1F305}", "\u{665A}\u{5B89} \u{1F319}"][band]
        case .en:
            return ["Good morning \u{2600}\u{FE0F}", "Good afternoon \u{1F324}\u{FE0F}", "Good evening \u{1F305}", "Good night \u{1F319}"][band]
        default:
            return ["Buongiorno \u{2600}\u{FE0F}", "Buon pomeriggio \u{1F324}\u{FE0F}", "Buonasera \u{1F305}", "Buonanotte \u{1F319}"][band]
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
