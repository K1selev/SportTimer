import SwiftUI

struct ActivityRingsView: View {
    let stats: [WorkoutStat]
    let viewModel: ActivityViewModel

    var body: some View {
        ZStack {
            ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                let progress = Double(stat.totalDuration) / 3600.0 / viewModel.goal(for: stat.type)
                let baseColor = WorkoutType(rawValue: stat.type)?.color ?? .gray
                let opacity = progress > 1 ? 0.4 : 1.0

                Circle()
                    .trim(from: 0, to: min(progress.truncatingRemainder(dividingBy: 1), 1.0))
                    .stroke(
                        baseColor.opacity(1),
                        style: StrokeStyle(lineWidth: CGFloat(10), lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: CGFloat(200 - index * 25), height: CGFloat(200 - index * 25))

                if progress > 1 {
                    Text("\(Int(progress))x")
                        .font(.caption)
                        .foregroundColor(baseColor)
                        .offset(y: CGFloat(-90 + index * 10))
                }
            }
        }
    }
}



struct RingView: View {
    let progress: Double
    let thickness: CGFloat
    let color: Color
    let inset: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(style: StrokeStyle(lineWidth: thickness, lineCap: .round))
            .foregroundColor(color)
            .rotationEffect(.degrees(-90))
            .padding(inset)
    }
}
