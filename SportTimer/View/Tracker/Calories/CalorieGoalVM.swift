//
//  CalorieGoalVM.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.
//

import Foundation

// ВАЖНО: здесь НЕ объявляем Gender/ActivityLevel повторно.
// Используем те же типы, что и в калькуляторе воды.

@MainActor
final class CalorieGoalVM: ObservableObject {
    enum Goal: CaseIterable {
        case maintain, lose, gain
        var title: String {
            switch self {
            case .maintain: return "Поддержание"
            case .lose:     return "Похудение"
            case .gain:     return "Набор"
            }
        }
        var multiplier: Double {
            switch self {
            case .maintain: return 1.0
            case .lose:     return 0.85   // −15%
            case .gain:     return 1.15   // +15%
            }
        }
    }

    @Published var gender: Gender? = nil            // используем существующий тип
    @Published var activity: ActivityLevel = .medium
    @Published var age: String = ""
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var goalType: Goal = .maintain
    @Published var resultKcal: Int? = nil

    var canCalculate: Bool {
        gender != nil && Int(age) != nil && Int(weight) != nil && Int(height) != nil
    }

    func toggleGender() {
        if gender == .male { gender = .female } else { gender = .male }
    }

    func cycleActivity() {
        switch activity {
        case .low:    activity = .medium
        case .medium: activity = .high
        case .high:   activity = .low
        }
    }

    func calculate() {
        guard let g = gender,
              let a = Int(age), let w = Int(weight), let h = Int(height) else { return }

        // Mifflin–St Jeor
        let bmr: Double = (g == .male)
        ? (10 * Double(w) + 6.25 * Double(h) - 5 * Double(a) + 5)
        : (10 * Double(w) + 6.25 * Double(h) - 5 * Double(a) - 161)

        let activityFactor: Double = {
            switch activity {
            case .low:    return 1.2
            case .medium: return 1.375
            case .high:   return 1.55
            }
        }()

        let tdee = bmr * activityFactor
        let target = tdee * goalType.multiplier

        // округляем к ближайшим 50 ккал
        let rounded = Int((target / 50.0).rounded() * 50.0)
        resultKcal = max(800, min(5000, rounded))
    }
}
