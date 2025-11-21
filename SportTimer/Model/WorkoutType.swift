//
//  WorkoutType.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//

import Foundation
import SwiftUI

enum WorkoutType: String, CaseIterable {
    case strength = "Силовая"
    case cardio = "Кардио"
    case yoga = "Йога"
    case swimming = "Плавание"
    case other = "Другое"
}

// MARK: - HEX → Color
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Палитра приложения
enum AppColors {
    static let blue   = Color(hex: 0x92A3FD)
    static let purple = Color(hex: 0xC58BF2)
    static let yellow = Color(hex: 0xFAD96D)
    static let neutral = Color(.systemGray3)
}

// MARK: - Цвета типов тренировок
extension WorkoutType {
    var color: Color {
        switch self {
        case .cardio:    return AppColors.yellow
        case .strength:  return AppColors.purple
        case .swimming:  return AppColors.blue
        case .yoga: return Color(hex: 0xAFAFFB)
        case .other:     return AppColors.neutral
        }
    }
}

extension Workout {
    var color: Color {
        WorkoutType(rawValue: type)?.color ?? .gray
    }
}
