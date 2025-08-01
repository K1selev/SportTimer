//
//  WorkoutType.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
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


extension WorkoutType {
    var color: Color {
        switch self {
        case .cardio: return .orange
        case .strength: return .red
        case .swimming: return .blue
        case .yoga: return .green
        case .other: return .gray
        }
    }
}

extension Workout {
    var color: Color {
        WorkoutType(rawValue: type)?.color ?? .gray
    }
}
