import SwiftUI
import AVFoundation

struct ParentZoneView: View {
    @Environment(PersistenceService.self) private var persistence
    @State private var showPronunciation = false
    let onBack: () -> Void
    let onReset: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Today's progress
                todayCard
                    .padding(.horizontal, 20)

                // Exposure chart
                ExposureChart(
                    weeklySeconds: persistence.state.weeklyListeningSeconds,
                    currentStreak: persistence.state.currentStreak,
                    longestStreak: persistence.state.longestStreak,
                    selectedLanguages: persistence.state.selectedLanguages.compactMap { Language(rawValue: $0) }
                )
                .padding(.horizontal, 20)

                // Recent sessions
                recentSessionsCard
                    .padding(.horizontal, 20)

                // Research tip
                researchCard
                    .padding(.horizontal, 20)

                // Privacy receipt
                privacyCard
                    .padding(.horizontal, 20)

                // Pronunciation guide
                pronunciationButton
                    .padding(.horizontal, 20)

                // Settings
                SettingsView(onReset: onReset)
                    .padding(.horizontal, 20)

                Color.clear.frame(height: 32)
            }
            .readableContentWidth(860)
        }
        .background(Color.cream)
        .sheet(isPresented: $showPronunciation) {
            PronunciationGuideView()
        }
    }

    private var pronunciationButton: some View {
        Button { showPronunciation = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "character.book.closed.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.coral)
                    .frame(width: 40, height: 40)
                    .background(Color.coral.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pronunciation Guide")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(Color.bark)
                    Text("Lyrics with pinyin · tap a line to hear it")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.stone)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.mist)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Pronunciation guide. Lyrics with pinyin, tap a line to hear it.")
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Home")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color.coral)
            }
            .accessibilityLabel("Back to home")
            .accessibilityAddTraits(.isButton)

            Spacer()

            Text("Parent Zone")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            Spacer()

            // Invisible spacer to center title
            Color.clear.frame(width: 60, height: 1)
        }
    }

    // MARK: - Today's Progress Card

    private var selectedLangs: [Language] {
        persistence.state.selectedLanguages.compactMap { Language(rawValue: $0) }
    }

    private var todayCard: some View {
        let todaySessions = sessionsToday
        let todayMinutes = todaySessions.reduce(0) { $0 + $1.durationSeconds } / 60
        let langsToday = Set(todaySessions.flatMap(\.languagesHeard))

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.coral)
                Text("Today")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
            }

            HStack(spacing: 16) {
                // Songs played
                VStack(spacing: 4) {
                    Text("\(todaySessions.count)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color.bark)
                    Text("songs")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.stone)
                }

                // Minutes
                VStack(spacing: 4) {
                    Text("\(todayMinutes)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color.bark)
                    Text("min")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.stone)
                }

                Spacer()

                // Language checks (only selected)
                HStack(spacing: 8) {
                    ForEach(selectedLangs) { lang in
                        VStack(spacing: 4) {
                            Text(lang.flag)
                                .font(.system(size: 18))
                            Image(systemName: langsToday.contains(lang.rawValue) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 16))
                                .foregroundStyle(langsToday.contains(lang.rawValue) ? lang.primaryColor : Color.sand)
                        }
                    }
                }
            }

            // Motivational copy
            if todaySessions.isEmpty {
                Text("No songs yet today. Start a session to build your streak!")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
            } else {
                let missing = selectedLangs.filter { !langsToday.contains($0.rawValue) }
                if missing.isEmpty {
                    let langCount = selectedLangs.count == 2 ? "Both" : "All \(selectedLangs.count)"
                    Text("\(langCount) languages heard today \u{2014} amazing!")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.italianGreen)
                } else {
                    let names = missing.map(\.displayName).joined(separator: " & ")
                    Text("Try a \(names) song to complete today's set!")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.stone)
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Recent Sessions

    private var recentSessionsCard: some View {
        let grouped = last7DaysGrouped

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.englishBlue)
                Text("Recent Sessions")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
            }

            if grouped.isEmpty {
                Text("No sessions recorded yet.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.stone)
                    .padding(.vertical, 8)
            } else {
                ForEach(grouped, id: \.date) { day in
                    dayRow(day: day)
                }
            }
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    private func dayRow(day: DayGroup) -> some View {
        HStack(spacing: 10) {
            // Day dot
            Circle()
                .fill(day.isToday ? Color.coral : Color.italianGreen)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(day.label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bark)
                let langs = Set(day.sessions.flatMap(\.languagesHeard))
                let flags = Language.allCases.filter { langs.contains($0.rawValue) }.map(\.flag).joined(separator: " ")
                Text("\(day.sessions.count) song\(day.sessions.count == 1 ? "" : "s") \u{00B7} \(day.totalMinutes) min \u{00B7} \(flags)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Research Card

    private var researchCard: some View {
        let tips = [
            "Each language needs ~25% of waking input for active production (Montanari, 2013).",
            "Children can distinguish 3+ languages by 8 months. Consistent daily exposure is key.",
            "Singing activates both language and music brain centers, boosting retention by 40%.",
            "Bilingual children show enhanced executive function by age 3 (Bialystok, 2011).",
        ]
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let tipIndex = (dayIndex - 1) % tips.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.englishBlue)
                Text("Research Corner")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
            }
            Text(tips[tipIndex])
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.stone)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Data Helpers

    private var sessionsToday: [ListeningSession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return persistence.state.sessions.filter { calendar.startOfDay(for: $0.date) == today }
    }

    private struct DayGroup {
        let date: Date
        let sessions: [ListeningSession]
        var isToday: Bool {
            Calendar.current.isDateInToday(date)
        }
        var label: String {
            if Calendar.current.isDateInToday(date) { return "Today" }
            if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        var totalMinutes: Int {
            sessions.reduce(0) { $0 + $1.durationSeconds } / 60
        }
    }

    private var last7DaysGrouped: [DayGroup] {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentSessions = persistence.state.sessions.filter { $0.date >= sevenDaysAgo }

        var dayMap: [Date: [ListeningSession]] = [:]
        for session in recentSessions {
            let day = calendar.startOfDay(for: session.date)
            dayMap[day, default: []].append(session)
        }

        return dayMap.keys.sorted(by: >).map { date in
            DayGroup(date: date, sessions: dayMap[date]!)
        }
    }

    // MARK: - Privacy Card

    private var privacyCard: some View {
        let lines = [
            "This data lives only on this iPhone.",
            "No accounts, no network calls, no tracking.",
            "Nothing here ever leaves the device.",
        ]
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.italianGreen)
                Text("Stays on This Device")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(lines, id: \.self) { line in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.italianGreen)
                        Text(line)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.stone)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Privacy: this data stays on this device. No accounts, no network calls, no tracking. Nothing ever leaves the device.")
    }
}

#if DEBUG
#Preview {
    ParentZoneView(onBack: {}, onReset: {})
        .environment(PersistenceService())
}
#endif

// MARK: - Pronunciation Guide (parent-gated)

/// Browse every song's lyrics with romanization (pinyin under Chinese lines) so the
/// non-native parent can read along; tap any line to hear that exact segment.
struct PronunciationGuideView: View {
    @Environment(\.dismiss) private var dismiss
    private let catalog = SongCatalogService()

    var body: some View {
        NavigationStack {
            List {
                ForEach(catalog.allSongs) { song in
                    NavigationLink {
                        SongLyricsView(song: song)
                    } label: {
                        HStack(spacing: 12) {
                            Text(song.icon).font(.system(size: 26))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title(for: song.primaryLanguage))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.bark)
                                Text(song.availableLanguages.map(\.flag).joined(separator: " "))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pronunciation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct SongLyricsView: View {
    let song: Song
    @State private var player = LyricPreviewPlayer()
    @State private var playingKey: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(song.availableLanguages) { lang in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Text(lang.flag)
                            Text(lang.displayName)
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(lang.primaryColor)
                        }

                        let lines = song.lyrics[lang.rawValue] ?? []
                        ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                            let key = "\(lang.rawValue)-\(idx)"
                            Button {
                                player.play(file: song.audioFile(for: lang), from: line.time)
                                playingKey = key
                            } label: {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: playingKey == key ? "speaker.wave.2.fill" : "play.circle")
                                        .font(.system(size: 14))
                                        .foregroundStyle(lang.primaryColor)
                                        .padding(.top, 2)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(line.text)
                                            .font(.system(size: lang == .zh ? 18 : 16, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color.bark)
                                            .multilineTextAlignment(.leading)
                                        if let r = line.romanization {
                                            Text(r)
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundStyle(Color.stone)
                                                .italic()
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(playingKey == key ? lang.backgroundColor : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Color.clear.frame(height: 24)
            }
            .padding(20)
            .readableContentWidth(720)
        }
        .background(Color.cream)
        .navigationTitle(song.title(for: song.primaryLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { player.stop() }
    }
}

@MainActor
@Observable
final class LyricPreviewPlayer {
    private var player: AVAudioPlayer?

    func play(file: String?, from time: Double) {
        stop()
        guard let file, let url = SongCatalogService.audioURL(for: file),
              let p = try? AVAudioPlayer(contentsOf: url) else { return }
        p.currentTime = max(0, time)
        p.play()
        player = p
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
