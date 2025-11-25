//
//  CupCounterView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//



import SwiftUI

struct CupCounterView: View {
    let ml: Int
    let count: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRemove: () -> Void   // NEW

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .frame(width: 56, height: 72)

                // если 0 — серая заливка, иначе фирменный градиент
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(count == 0 ? AnyShapeStyle(Color(.systemGray4))
                                     : AnyShapeStyle(WaterTheme.blueGradient))
                    .frame(width: 56, height: 72 * 0.75)
                    .mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .opacity(0.95)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { v in
                        // реагируем только на ВЕРТИКАЛЬНЫЙ свайп вверх
                        if abs(v.translation.height) > abs(v.translation.width),
                           v.translation.height < -20 {
                            if count == 0 {
                                // если уже 0 — удаляем стакан из списка
                                onRemove()
                            } else {
                                onDecrement()
                            }
                        }
                    }
            )
            .onTapGesture { onIncrement() }

            Text("x\(count)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Text("\(ml) мл")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 64)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Стакан \(ml) миллилитров, выпито \(count)")
    }
}
