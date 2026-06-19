import AVFoundation
import MediaPlayer

@Observable
@MainActor
final class AudioService: NSObject {
    // MARK: - Published State
    private(set) var isPlaying: Bool = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var progress: Double = 0
    private(set) var currentSegment: Int = 0

    // MARK: - Private
    private var player: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var segments: [(file: String, language: Language)] = []
    private var currentSong: Song?
    private var onSegmentChange: ((Int) -> Void)?
    private var onPlaybackComplete: (() -> Void)?

    // Total duration across all segments for progress calculation
    private var segmentDurations: [TimeInterval] = []
    private var totalDuration: TimeInterval = 0

    /// Public read-only accessor for actual segment durations
    var segmentDurationsList: [TimeInterval] { segmentDurations }

    /// Public read-only accessor for segment languages
    var segmentLanguages: [Language] { segments.map(\.language) }

    override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommands()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    // MARK: - Playback Control

    func loadSong(_ song: Song, selectedLanguages: [Language] = [.it, .zh, .en]) {
        stop()
        currentSong = song
        segments = []
        segmentDurations = []

        if song.isCrossCultural {
            // Play only selected languages, in IT → ZH → EN order
            let playOrder: [Language] = [.it, .zh, .en].filter { selectedLanguages.contains($0) }
            for lang in playOrder {
                if let file = song.audioFile(for: lang) {
                    segments.append((file: file, language: lang))
                }
            }
        } else {
            let lang = song.primaryLanguage
            if let file = song.audioFile(for: lang) {
                segments.append((file: file, language: lang))
            }
        }

        // Pre-calculate segment durations
        for segment in segments {
            if let url = SongCatalogService.audioURL(for: segment.file),
               let tempPlayer = try? AVAudioPlayer(contentsOf: url) {
                segmentDurations.append(tempPlayer.duration)
            } else {
                segmentDurations.append(0)
            }
        }
        totalDuration = segmentDurations.reduce(0, +)
        duration = totalDuration

        currentSegment = 0
    }

    func play() {
        guard !segments.isEmpty else { return }
        if player == nil {
            loadSegment(currentSegment)
        }
        player?.play()
        isPlaying = true
        startDisplayLink()
        updateNowPlaying()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopDisplayLink()
        updateNowPlaying()
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
        progress = 0
        currentSegment = 0
        stopDisplayLink()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func restart() {
        currentSegment = 0
        loadSegment(0)
        play()
    }

    func skipToSegment(index: Int) {
        guard index >= 0, index < segments.count else { return }
        currentSegment = index
        loadSegment(index)
        if isPlaying {
            player?.play()
            updateNowPlaying()
        }
        onSegmentChange?(index)
    }

    func seek(to normalizedProgress: Double) {
        guard !segments.isEmpty, totalDuration > 0 else { return }
        let targetTime = max(0, min(normalizedProgress, 1.0)) * totalDuration

        // Find which segment this time falls in
        var accumulated: TimeInterval = 0
        for (i, dur) in segmentDurations.enumerated() {
            if targetTime < accumulated + dur || i == segmentDurations.count - 1 {
                let timeInSegment = targetTime - accumulated
                if i != currentSegment {
                    currentSegment = i
                    loadSegment(i)
                    onSegmentChange?(i)
                }
                player?.currentTime = min(timeInSegment, dur)
                if isPlaying {
                    player?.play()
                }
                updateProgress()
                updateNowPlaying()
                return
            }
            accumulated += dur
        }
    }

    func skipToNext() {
        onPlaybackComplete?()
    }

    func setOnSegmentChange(_ handler: @escaping (Int) -> Void) {
        onSegmentChange = handler
    }

    func setOnPlaybackComplete(_ handler: @escaping () -> Void) {
        onPlaybackComplete = handler
    }

    // MARK: - Segment Loading

    private func loadSegment(_ index: Int) {
        guard index < segments.count else { return }
        let segment = segments[index]

        guard let url = SongCatalogService.audioURL(for: segment.file) else {
            print("Audio file not found: \(segment.file)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("Failed to load audio: \(error)")
        }
    }

    // MARK: - Display Link for Progress Updates

    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 10, maximum: 30, preferred: 15)
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateProgress() {
        guard let player else { return }

        let elapsedInPriorSegments = segmentDurations.prefix(currentSegment).reduce(0, +)
        currentTime = elapsedInPriorSegments + player.currentTime

        if totalDuration > 0 {
            progress = currentTime / totalDuration
        }
    }

    // MARK: - Now Playing

    private func updateNowPlaying() {
        guard let song = currentSong else { return }
        let lang = currentSegment < segments.count ? segments[currentSegment].language : song.primaryLanguage

        // Global elapsed time across all segments (lock-screen scrubber must match
        // the in-app progress bar, which spans the whole IT→ZH→EN sequence).
        let elapsedInPriorSegments = segmentDurations.prefix(currentSegment).reduce(0, +)
        let globalElapsed = elapsedInPriorSegments + (player?.currentTime ?? 0)

        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = song.title(for: lang)
        info[MPMediaItemPropertyArtist] = "Tre Voci"
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = globalElapsed
        info[MPMediaItemPropertyPlaybackDuration] = totalDuration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote Commands

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.play() }
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.skipToNext() }
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.restart() }
            return .success
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard flag else { return }
            let nextSegment = currentSegment + 1
            if nextSegment < segments.count {
                currentSegment = nextSegment
                loadSegment(nextSegment)
                onSegmentChange?(nextSegment)
                // Brief pause between language segments for smoother transition
                try? await Task.sleep(for: .milliseconds(500))
                self.player?.play()
                updateNowPlaying()
            } else {
                // All segments finished
                isPlaying = false
                stopDisplayLink()
                onPlaybackComplete?()
            }
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
        Task { @MainActor in
            print("Audio decode error: \(error?.localizedDescription ?? "unknown")")
            isPlaying = false
            stopDisplayLink()
        }
    }
}
