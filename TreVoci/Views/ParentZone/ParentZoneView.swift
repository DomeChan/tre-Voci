import SwiftUI

struct ParentZoneView: View {
    @Environment(PersistenceService.self) private var persistence
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

                // Settings
                SettingsView(onReset: onReset)
                    .padding(.horizontal, 20)

                Color.clear.frame(height: 32)
            }
        }
        .background(Color.cream)
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
}

#if DEBUG
#Preview {
    ParentZoneView(onBack: {}, onReset: {})
        .environment(PersistenceService())
}
#endif
