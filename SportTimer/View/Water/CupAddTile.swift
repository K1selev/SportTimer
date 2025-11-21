//
//  CupAddTile.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import SwiftUI

struct CupAddTile: View {
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .frame(width: 56, height: 72)

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(WaterTheme.blueGradient)
            }
            .onTapGesture { onTap() }

            Text("свой")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)

            Text("мл")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 64)
        .accessibilityLabel("Добавить свой объём")
    }
}
