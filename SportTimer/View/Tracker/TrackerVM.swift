//
//  TrackerVM.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.
//

import SwiftUI

final class TrackerVM: ObservableObject {
    // Вода
    @AppStorage("water.dailyGoalML")  var waterGoalML: Int = 2000
    @AppStorage("water.todayTotalML") var waterTodayML: Int = 0

    // Шаги
    @AppStorage("steps.dailyGoal")    var stepsGoal: Int = 8000
    @AppStorage("steps.today")        var stepsToday: Int = 0

    // Сон
    @AppStorage("sleep.goalH")        var sleepGoalH: Double = 8
    @AppStorage("sleep.todayMin")     var sleepTodayMin: Int = 0

    // Питание
    @AppStorage("nutrition.goalKcal")  var kcalGoal: Int = 2000
    @AppStorage("nutrition.todayKcal") var kcalToday: Int = 0

    // Прогрессы 0...1
    var waterProgress: Double {
        guard waterGoalML > 0 else { return 0 }
        return min(Double(waterTodayML) / Double(waterGoalML), 1)
    }

    var stepsProgress: Double {
        guard stepsGoal > 0 else { return 0 }
        return min(Double(stepsToday) / Double(stepsGoal), 1)
    }

    var sleepProgress: Double {
        let goalMin = Int(sleepGoalH * 60)
        guard goalMin > 0 else { return 0 }
        return min(Double(sleepTodayMin) / Double(goalMin), 1)
    }

    var kcalProgress: Double {
        guard kcalGoal > 0 else { return 0 }
        return min(Double(kcalToday) / Double(kcalGoal), 1)
    }
}
