//
//  AvatarParts.swift
//  SportTimer
//
//  Created by Сергей Киселев on 21.11.2025.
//
//
//  AvatarParts.swift
//  SportTimer
//

//
//  AvatarParts.swift
//  SportTimer
//

import SwiftUI

// MARK: - Eyes (используется в сетке «Лицо»)

struct EyesView: View {
    let style: EyeStyle

    var body: some View {
        HStack(spacing: 28) {
            eye; eye
        }
        .frame(width: 140, height: 60)
        .offset(y: -12)
    }

    private var eye: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .frame(width: 44, height: 36)
            pupil
        }
    }

    @ViewBuilder private var pupil: some View {
        switch style {
        case .normal:
            Circle().fill(Color.black)
                .frame(width: 16, height: 16)
                .offset(x: 2)
        case .happy:
            Circle()
                .stroke(lineWidth: 3)
                .frame(width: 22, height: 18)
                .offset(y: 4)
        case .sleepy:
            Capsule()
                .fill(Color.black)
                .frame(width: 22, height: 3)
        }
    }
}

// MARK: - Glasses (для мини-превью в сетке «Очки»)

struct GlassesView: View {
    let style: Glasses

    var body: some View {
        switch style {
        case .none:
            EmptyView()
        case .round:
            HStack(spacing: 18) {
                Circle()
                    .stroke(Color.black.opacity(0.8), lineWidth: 3)
                    .frame(width: 38, height: 38)
                Circle()
                    .stroke(Color.black.opacity(0.8), lineWidth: 3)
                    .frame(width: 38, height: 38)
            }
            .offset(y: -8)
        case .square:
            HStack(spacing: 18) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.8), lineWidth: 3)
                    .frame(width: 40, height: 34)
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.8), lineWidth: 3)
                    .frame(width: 40, height: 34)
            }
            .offset(y: -8)
        case .sunglasses:
            HStack(spacing: 16) {
                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: 44, height: 26)
                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: 44, height: 26)
            }
            .offset(y: -6)
        }
    }
}
