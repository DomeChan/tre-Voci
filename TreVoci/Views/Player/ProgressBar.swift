import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let segmentCount: Int
    let currentSegment: Int
    var languages: [Language] = [.it, .zh, .en]
    var onSeek: ((Double) -> Void)?

    @State private var isDragging = false

    private let trackHeight: CGFloat = 6
    private let hitHeight: CGFloat = 44
    private let thumbSize: CGFloat = 22

    private var activeColor: Color {
        if currentSegment < languages.count {
            return languages[currentSegment].primaryColor
        }
        return .coral
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let thumbX = max(0, min(progress * geo.size.width, geo.size.width))

                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: trackHeight)

                    // Filled track
                    if segmentCount > 1 {
                        triColorBar(width: geo.size.width)
                    } else {
                        singleColorBar(width: geo.size.width)
                    }

                    // Glass thumb
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .fill(activeColor.opacity(0.5))
                                .padding(2)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                        )
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: activeColor.opacity(0.4), radius: isDragging ? 8 : 4, y: 0)
                        .scaleEffect(isDragging ? 1.3 : 1.0)
                        .position(x: thumbX, y: hitHeight / 2)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDragging)
                }
                .frame(height: hitHeight)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let fraction = max(0, min(value.location.x / geo.size.width, 1.0))
                            onSeek?(fraction)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            }
            .frame(height: hitHeight)

            // Segment labels
            if segmentCount > 1 {
                segmentLabels
            }
        }
    }

    // MARK: - Tri-Color (Cross-Cultural)

    private func triColorBar(width: CGFloat) -> some View {
        let segmentWidth = width / CGFloat(segmentCount)

        return HStack(spacing: 0) {
            ForEach(0..<segmentCount, id: \.self) { i in
                let segmentProgress = segmentFill(for: i)
                let color = i < languages.count ? languages[i].primaryColor : Color.coral
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.clear)

                    Rectangle()
                        .fill(color)
                        .frame(width: segmentWidth * segmentProgress)
                        .animation(.linear(duration: 0.15), value: segmentProgress)
                }
                .frame(width: segmentWidth)
            }
        }
        .frame(height: trackHeight)
        .clipShape(RoundedRectangle(cornerRadius: trackHeight / 2))
    }

    // MARK: - Single Color (Culture-Specific)

    private func singleColorBar(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: trackHeight / 2)
            .fill(Color.coral)
            .frame(width: max(0, width * progress), height: trackHeight)
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
            ForEach(0..<segmentCount, id: \.self) { i in
                if i < languages.count {
                    let lang = languages[i]
                    HStack(spacing: 2) {
                        Text(lang.flag)
                            .font(.system(size: 10))
                        Text(lang.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(i == currentSegment ? lang.primaryColor : Color.white.opacity(0.5))
                    }
                    if i < segmentCount - 1 {
                        Spacer()
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 30) {
        ProgressBar(progress: 0.4, segmentCount: 3, currentSegment: 1)
        ProgressBar(progress: 0.5, segmentCount: 2, currentSegment: 1, languages: [.it, .en])
        ProgressBar(progress: 0.6, segmentCount: 1, currentSegment: 0)
    }
    .padding(30)
    .background(Color.black.opacity(0.3))
}
#endif
