//
//  WaterBarChart.swift
//  SportTimer
//



import SwiftUI

struct WaterBarChart: View {
    let valuesML: [Int]
    let goalML: Int

    private let days = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]

    var body: some View {
        GeometryReader { geo in
            let barSpacing: CGFloat = 12
            let labelsHeight: CGFloat = 20
            let totalSpacing: CGFloat = barSpacing * 6
            let availableWidth = max(geo.size.width - totalSpacing, 1)
            let availableHeight = max(geo.size.height - labelsHeight, 1)
            let barWidth = availableWidth / 7

            let maxValue = max(goalML, valuesML.max() ?? 1)
            let goalRatio = CGFloat(goalML) / CGFloat(maxValue)
            let goalY = (1 - goalRatio) * availableHeight

            ZStack(alignment: .topLeading) {
                // Пунктирная линия цели
                Path { p in
                    p.move(to: CGPoint(x: 0, y: goalY))
                    p.addLine(to: CGPoint(x: geo.size.width - 28, y: goalY))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4,4]))
                .foregroundColor(.black.opacity(0.25))

                // Подпись цели справа
                let liters = Double(goalML) / 1000.0
                Text(String(format: "%.0f л", liters.rounded(.toNearestOrEven)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .position(x: geo.size.width - 12, y: goalY)

                VStack {
                    Spacer(minLength: 0)
                    HStack(spacing: barSpacing) {
                        ForEach(0..<7, id: \.self) { idx in
                            let value = valuesML.indices.contains(idx) ? valuesML[idx] : 0
                            let ratio = CGFloat(value) / CGFloat(maxValue)
                            let barHeight = max(6, ratio * availableHeight)
                            let reached = value >= goalML

                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(.systemGray5))
                                    .frame(width: barWidth, height: barHeight)
                                    .overlay(
                                        (reached ? WaterTheme.blueGradient : WaterTheme.purpleGradient)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .frame(width: barWidth, height: barHeight)
                                            )
                                    )
                                Text(days[idx])
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .frame(width: barWidth)
                            }
                            .frame(height: availableHeight + labelsHeight, alignment: .bottom)
                        }
                    }
                }
            }
        }
    }
}
