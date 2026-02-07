import SwiftUI

@Observable
@MainActor
final class PlayerViewModel {
    // MARK: - Public State
    private(set) var currentLanguage: Language = .it
    private(set) var isPlaying: Bool = false
    private(set) var progress: Double = 0
    private(set) var currentTime: TimeInterval = 0
    private(set) var currentLyricIndex: Int = 0
    private(set) var currentSegment: Int = 0
    private(set) var showLanguageToast: Bool = false
    private(set) var toastLanguage: Language = .it

    let song: Song
    let selectedLanguages: [Language]
    let audioService = AudioService()

    // MARK: - Computed

    var currentTitle: String {
        song.title(for: currentLanguage)
    }

    var currentLyrics: [LyricLine] {
        song.lyrics[currentLanguage.rawValue] ?? []
    }

    var currentLyricText: String {
        guard !currentLyrics.isEmpty, currentLyricIndex < currentLyrics.count else {
            return ""
        }
        return currentLyrics[currentLyricIndex].text
    }

    var segmentCount: Int {
        song.isCrossCultural ? audioService.segmentLanguages.count : 1
    }

    var availableLanguages: [Language] {
        song.isCrossCultural ? audioService.segmentLanguages : song.availableLanguages
    }

    var duration: TimeInterval {
        audioService.duration
    }

    // MARK: - Init

    init(song: Song, selectedLanguages: [Language] = [.it, .zh, .en]) {
        self.song = song
        self.selectedLanguages = selectedLanguages
        self.currentLanguage = song.isCrossCultural
            ? ([.it, .zh, .en].first(where: { selectedLanguages.contains($0) }) ?? song.primaryLanguage)
            : song.primaryLanguage
        audioService.loadSong(song, selectedLanguages: selectedLanguages)
        setupCallbacks()
    }

    // MARK: - Playback Controls

    func play() {
        audioService.play()
        isPlaying = true
    }

    func pause() {
        audioService.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { play() }
    }

    func restart() {
        audioService.restart()
        currentSegment = 0
        currentLanguage = audioService.segmentLanguages.first ?? song.primaryLanguage
        currentLyricIndex = 0
        isPlaying = true
    }

    func seek(to progress: Double) {
        audioService.seek(to: progress)
        self.progress = progress
        currentSegment = audioService.currentSegment
        let langs = audioService.segmentLanguages
        if currentSegment < langs.count {
            currentLanguage = langs[currentSegment]
        }
        currentLyricIndex = 0
    }

    func skipToActivity() {
        audioService.stop()
        isPlaying = false
    }

    // MARK: - Language Switching

    func switchLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        guard song.audioFile(for: language) != nil else { return }

        currentLanguage = language
        currentLyricIndex = 0

        if song.isCrossCultural {
            if let segmentIndex = audioService.segmentLanguages.firstIndex(of: language) {
                currentSegment = segmentIndex
                audioService.skipToSegment(index: segmentIndex)
                if isPlaying {
                    audioService.play()
                }
            }
        }

        showToast(for: language)
    }

    // MARK: - Progress Tracking

    func updateState() {
        progress = audioService.progress
        currentTime = audioService.currentTime
        isPlaying = audioService.isPlaying
        currentSegment = audioService.currentSegment
        updateLyricIndex()
    }

    private func updateLyricIndex() {
        let lyrics = currentLyrics
        guard !lyrics.isEmpty else { return }

        // Find segment-local time for lyric matching
        let segmentTime = audioService.currentTime - segmentStartTime()

        var newIndex = 0
        for (i, line) in lyrics.enumerated() {
            if segmentTime >= line.time {
                newIndex = i
            }
        }

        if newIndex != currentLyricIndex {
            currentLyricIndex = newIndex
        }
    }

    private func segmentStartTime() -> TimeInterval {
        // For cross-cultural songs, calculate the offset of prior segments
        guard song.isCrossCultural else { return 0 }
        // Use actual segment durations instead of equal fractions
        return audioService.segmentDurationsList.prefix(currentSegment).reduce(0, +)
    }

    // MARK: - Callbacks

    private func setupCallbacks() {
        audioService.setOnSegmentChange { [weak self] segment in
            Task { @MainActor in
                guard let self else { return }
                self.currentSegment = segment
                let languages = self.audioService.segmentLanguages
                if segment < languages.count && self.song.isCrossCultural {
                    self.currentLanguage = languages[segment]
                    self.currentLyricIndex = 0
                    self.showToast(for: languages[segment])
                }
            }
        }

        audioService.setOnPlaybackComplete { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.isPlaying = false
            }
        }
    }

    // MARK: - Toast

    private func showToast(for language: Language) {
        toastLanguage = language
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showLanguageToast = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut(duration: 0.3)) {
                showLanguageToast = false
            }
        }
    }
}
