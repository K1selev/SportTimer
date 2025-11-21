//
//  ActivityViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.08.2025.
//

import SwiftUI

struct WorkoutGoal: Codable {
    var type: String
    var targetHours: Double
}

@MainActor
class ActivityViewModel: ObservableObject {
    @AppStorage("workoutGoals") private var storedGoalsData: Data = Data()
    @AppStorage("hasSetGoals") var hasSetGoals: Bool = false

    @Published var goals: [WorkoutGoal] = []
    @Published var showGoalInput: Bool = false

    init() {
        loadGoals()
        if !hasSetGoals {
            showGoalInput = true
        }
    }

    func loadGoals() {
        if let decoded = try? JSONDecoder().decode([WorkoutGoal].self, from: storedGoalsData) {
            goals = decoded
        }
    }

    func saveGoals(_ newGoals: [WorkoutGoal]) {
        goals = newGoals
        if let encoded = try? JSONEncoder().encode(newGoals) {
            storedGoalsData = encoded
            hasSetGoals = true
            showGoalInput = false
        }
    }

    func goal(for type: String) -> Double {
        goals.first(where: { $0.type == type })?.targetHours ?? 1.0
    }
}
