import SwiftUI

struct ExposureChart: View {
    let weeklySeconds: [String: Int]
    let currentStreak: Int
    let longestStreak: Int
    var selectedLanguages: [Language] = [.it, .zh, .en]

    private var itMinutes: Double { Double(weeklySeconds["it"] ?? 0) / 60.0 }
    private var zhMinutes: Double { Double(weeklySeconds["zh"] ?? 0) / 60.0 }
    private var enMinutes: Double { Double(weeklySeconds["en"] ?? 0) / 60.0 }
    private let targetMinutes: Double = 60

    private func minutes(for lang: Language) -> Double {
        Double(weeklySeconds[lang.rawValue] ?? 0) / 60.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Streak banner
            if currentStreak > 0 {
                streakBanner
            }

            Text("This Week's Exposure")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            // Weekly goal ring
            weeklyGoalRing
                .frame(height: 160)

            // Language breakdown cards (only selected)
            ForEach(selectedLanguages) { lang in
                languageCard(language: lang, minutes: minutes(for: lang), role: lang.familyRole + "'s language")
            }

            // Tip card
            tipCard
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: 8) {
            Text("\u{1F525}")
                .font(.system(size: streakIconSize))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(currentStreak)-Day Streak!")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
                if longestStreak > currentStreak {
                    Text("Best: \(longestStreak) days")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.stone)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color.coral.opacity(0.12), Color.rose.opacity(0.08)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var streakIconSize: CGFloat {
        switch currentStreak {
        case 1...3: return 20
        case 4...7: return 26
        case 8...14: return 30
        default: return 36
        }
    }

    // MARK: - Weekly Goal Ring

    private var weeklyGoalRing: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let ringWidth: CGFloat = 14
            let totalMinutes = selectedLanguages.reduce(0.0) { $0 + minutes(for: $1) }

            ZStack {
                // Background rings
                ForEach(0..<selectedLanguages.count, id: \.self) { i in
                    Circle()
                        .stroke(Color.sand.opacity(0.4), lineWidth: ringWidth)
                        .frame(width: size - CGFloat(i) * (ringWidth + 6), height: size - CGFloat(i) * (ringWidth + 6))
                }

                // Language rings
                ForEach(Array(selectedLanguages.enumerated()), id: \.element) { i, lang in
                    arcRing(
                        radius: size,
                        offset: i,
                        width: ringWidth,
                        progress: min(minutes(for: lang) / targetMinutes, 1.0),
                        color: lang.primaryColor
                    )
                }

                // Center text
                VStack(spacing: 2) {
                    Text("\(Int(totalMinutes))")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.bark)
                    Text("min total")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.stone)
                }
            }
            .position(center)
        }
    }

    private func arcRing(radius: CGFloat, offset: Int, width: CGFloat, progress: Double, color: Color) -> some View {
        let ringSize = radius - CGFloat(offset) * (width + 6)
        return Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: ringSize, height: ringSize)
    }

    // MARK: - Language Card

    private func languageCard(language: Language, minutes: Double, role: String) -> some View {
        HStack(spacing: 12) {
            Text(language.flag)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 3) {
                Text(language.displayName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bark)
                Text(role)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(Int(minutes)) min")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(language.primaryColor)
                Text("of \(Int(targetMinutes)) min goal")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
            }
        }
        .padding(12)
        .background(
            GeometryReader { geo in
                Rectangle()
                    .fill(language.primaryColor.opacity(0.1))
                    .frame(width: geo.size.width * min(minutes / targetMinutes, 1.0))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(language.primaryColor.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Tip Card

    private var tipCard: some View {
        let tip = generateTip()
        return HStack(alignment: .top, spacing: 10) {
            Text("\u{1F4A1}")
                .font(.system(size: 20))
            Text(tip)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.warm)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func generateTip() -> String {
        let langs: [(String, Double)] = selectedLanguages.map { ($0.displayName, minutes(for: $0)) }
        let sorted = langs.sorted { $0.1 < $1.1 }
        let lowest = sorted[0]
        let highest = sorted[sorted.count - 1]

        if highest.1 == 0 {
            return "Start your first listening session! Each language needs about 60 minutes per week."
        }

        let diff = highest.1 - lowest.1
        if diff < 5 {
            let langCount = selectedLanguages.count == 2 ? "both" : "all \(selectedLanguages.count)"
            return "Great balance! \(langCount.capitalized) languages are getting similar exposure this week."
        }

        let pct = Int((diff / max(highest.1, 1)) * 100)
        return "\(lowest.0) is \(pct)% below \(highest.0). Try a \(lowest.0) bedtime song tonight!"
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ExposureChart(
            weeklySeconds: ["it": 2400, "zh": 900, "en": 1800],
            currentStreak: 5,
            longestStreak: 12
        )
        .padding(20)
    }
    .background(Color.cream)
}
#endif
