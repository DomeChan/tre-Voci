import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let segmentCount: Int
    let currentSegment: Int

    private let height: CGFloat = 6

    var body: some View {
        VStack(spacing: 6) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.white.opacity(0.2))

                    if segmentCount > 1 {
                        triColorBar(width: geo.size.width)
                    } else {
                        singleColorBar(width: geo.size.width)
                    }
                }
            }
            .frame(height: height)

            // Segment labels
            if segmentCount > 1 {
                segmentLabels
            }
        }
    }

    // MARK: - Tri-Color (Cross-Cultural)

    private func triColorBar(width: CGFloat) -> some View {
        let segmentWidth = width / CGFloat(segmentCount)
        let colors: [Color] = [.italianGreen, .chineseRed, .englishBlue]

        return HStack(spacing: 0) {
            ForEach(0..<segmentCount, id: \.self) { i in
                let segmentProgress = segmentFill(for: i)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.clear)

                    Rectangle()
                        .fill(colors[i])
                        .frame(width: segmentWidth * segmentProgress)
                        .animation(.linear(duration: 0.15), value: segmentProgress)
                }
                .frame(width: segmentWidth)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }

    // MARK: - Single Color (Culture-Specific)

    private func singleColorBar(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.coral)
            .frame(width: max(0, width * progress))
            .animation(.linear(duration: 0.15), value: progress)
    }

    // MARK: - Segment Fill Calculation

    private func segmentFill(for index: Int) -> Double {
        let segmentSize = 1.0 / Double(segmentCount)
        let segmentStart = Double(index) * segmentSize
        let segmentEnd = segmentStart + segmentSize

        if progress >= segmentEnd {
            return 1.0
        } else if progress > segmentStart {
            return (progress - segmentStart) / segmentSize
        } else {
            return 0.0
        }
    }

    // MARK: - Segment Labels

    private var segmentLabels: some View {
        HStack {
            let labels = [
                ("🇮🇹", "IT", Color.italianGreen),
                ("🇨🇳", "ZH", Color.chineseRed),
                ("🇬🇧", "EN", Color.englishBlue)
            ]
            ForEach(0..<min(segmentCount, labels.count), id: \.self) { i in
                HStack(spacing: 2) {
                    Text(labels[i].0)
                        .font(.system(size: 10))
                    Text(labels[i].1)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(i == currentSegment ? labels[i].2 : Color.white.opacity(0.5))
                }
                if i < segmentCount - 1 {
                    Spacer()
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 30) {
        ProgressBar(progress: 0.4, segmentCount: 3, currentSegment: 1)
        ProgressBar(progress: 0.6, segmentCount: 1, currentSegment: 0)
    }
    .padding(30)
    .background(Color.black.opacity(0.3))
}
#endif
