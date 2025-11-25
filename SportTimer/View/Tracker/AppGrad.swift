//
//  AppGrad.swift
//  SportTimer
//
//  Created by Сергей Киселев on 24.11.2025.
//

import SwiftUI

// MARK: - Палитра / Градиенты
enum AppGrad {
    static let blue   = Color(red: 146/255, green: 163/255, blue: 253/255) // #92A3FD
    static let purple = Color(red: 197/255, green: 139/255, blue: 242/255) // #C58BF2
    static let gradient = LinearGradient(colors: [blue, purple], startPoint: .leading, endPoint: .trailing)

    static let screenBG = LinearGradient(
        colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let cardBlueBG = LinearGradient(
        colors: [
            blue.opacity(0.18),
            purple.opacity(0.10)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - Прогресс-бар с процентом (чёрные проценты, заливка слева направо)
struct ProgressBar: View {
    let progress: Double

    private var percentText: String {
        "\(Int(round(progress * 100)))%"
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h: CGFloat = 12

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.6))
                    .frame(height: h)

                Capsule()
                    .fill(AppGrad.gradient)
                    .frame(width: max(0, min(1, CGFloat(progress))) * w, height: h)
                    .animation(.easeInOut(duration: 0.25), value: progress)
            }
            .overlay(
                Text(percentText)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
            )
        }
        .frame(height: 12)
    }
}

// MARK: - Карточка
struct TrackerCard: View {
    let icon: Image
    let titleValue: String
    let subtitle: String
    let progress: Double
    let tappable: Bool

    var body: some View {
        ZStack {
            // фон карточки — голубой градиент как на макете
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppGrad.cardBlueBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)

            HStack(alignment: .center, spacing: 14) {
                icon
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.8))
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(titleValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppGrad.blue)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ProgressBar(progress: progress)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(tappable ? .secondary : .clear)
            }
            .padding(16)
        }
        .opacity(tappable ? 1 : 0.92)
    }
}
