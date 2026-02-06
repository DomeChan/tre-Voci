import SwiftUI

struct ExposureChart: View {
    let weeklySeconds: [String: Int]

    private var itMinutes: Double { Double(weeklySeconds["it"] ?? 0) / 60.0 }
    private var zhMinutes: Double { Double(weeklySeconds["zh"] ?? 0) / 60.0 }
    private var enMinutes: Double { Double(weeklySeconds["en"] ?? 0) / 60.0 }
    private var maxMinutes: Double { max(max(itMinutes, max(zhMinutes, enMinutes)), 1) }
    private let targetMinutes: Double = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week's Exposure")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            // Chart
            chartView
                .frame(height: 180)

            // Tip card
            tipCard
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Chart

    private var chartView: some View {
        let barData: [(Language, Double, Color)] = [
            (.it, itMinutes, .italianGreen),
            (.zh, zhMinutes, .chineseRed),
            (.en, enMinutes, .englishBlue),
        ]
        let chartMax = max(maxMinutes, targetMinutes) * 1.2

        return GeometryReader { geo in
            let barWidth: CGFloat = 56
            let spacing = (geo.size.width - barWidth * 3) / 4

            ZStack(alignment: .bottomLeading) {
                // Dashed target line
                let targetY = geo.size.height * (1 - targetMinutes / chartMax)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: targetY))
                    path.addLine(to: CGPoint(x: geo.size.width, y: targetY))
                }
                .stroke(Color.stone, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))

                Text("\(Int(targetMinutes))m target")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.stone)
                    .position(x: geo.size.width - 36, y: targetY - 10)

                // Bars
                HStack(alignment: .bottom, spacing: spacing) {
                    Spacer(minLength: 0)
                    ForEach(Array(barData.enumerated()), id: \.0) { _, item in
                        let (lang, minutes, color) = item
                        let barHeight = max(4, geo.size.height * minutes / chartMax)
                        VStack(spacing: 4) {
                            // Minutes label
                            Text("\(Int(minutes))m")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(color)

                            // Bar
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color)
                                .frame(width: barWidth, height: barHeight)

                            // Flag + label
                            Text("\(lang.flag) \(lang.rawValue.uppercased())")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.stone)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
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
        let langs: [(String, Double)] = [
            ("Italian", itMinutes),
            ("Mandarin", zhMinutes),
            ("English", enMinutes),
        ]
        let sorted = langs.sorted { $0.1 < $1.1 }
        let lowest = sorted[0]
        let highest = sorted[2]

        if highest.1 == 0 {
            return "Start your first listening session! Each language needs about 60 minutes per week."
        }

        let diff = highest.1 - lowest.1
        if diff < 5 {
            return "Great balance! All three languages are getting similar exposure this week."
        }

        let pct = Int((diff / max(highest.1, 1)) * 100)
        return "\(lowest.0) is \(pct)% below \(highest.0). Try a \(lowest.0) bedtime song tonight!"
    }
}

#if DEBUG
#Preview {
    ExposureChart(weeklySeconds: ["it": 2400, "zh": 900, "en": 1800])
        .padding(20)
        .background(Color.cream)
}
#endif
