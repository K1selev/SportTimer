//
//  WaterIntakeViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.

//
//  WaterIntakeViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import Foundation
import SwiftUI

@MainActor
final class WaterIntakeVM: ObservableObject {
    @Published var goalML: Int = 2000
    @Published var todayCounts: [Int:Int] = [:]
    @Published var weekBars: [Int] = Array(repeating: 0, count: 7)
    @Published var cups: [Int] = [200, 250, 300, 500]
    @AppStorage("water.dailyGoalML")  private var storedGoalML: Int = 2000
    @AppStorage("water.todayTotalML") private var storedTodayML: Int = 0

    private let service: WaterServiceProtocol
    private let calendar = Calendar.current

    init(service: WaterServiceProtocol = UserDefaultsWaterService()) {
        self.service = service
    }

    // MARK: - Lifecycle

    func onAppear() async {
        goalML = await service.loadGoal()
        await reloadToday()
        await reloadWeek()
        syncAppStorage()
    }

    // MARK: - Actions

    func addCustomCup(ml: Int) {
        guard ml > 0 else { return }
        if !cups.contains(ml) {
            cups.append(ml)
            cups.sort()
        }
    }

    func removeCup(_ ml: Int) {
        if let idx = cups.firstIndex(of: ml) {
            cups.remove(at: idx)
        }
        syncAppStorage()
    }

    func increment(_ cupML: Int) async {
        await service.increment(cupML: cupML, on: Date())
        await reloadToday()
        await reloadWeek()
        syncAppStorage()
    }

    func decrement(_ cupML: Int) async {
        await service.decrement(cupML: cupML, on: Date())
        await reloadToday()
        await reloadWeek()
        syncAppStorage()
    }

    func setGoal(_ ml: Int) async {
        await service.saveGoal(ml)
        goalML = ml
        await reloadWeek()
        syncAppStorage()
    }
    var todayTotalML: Int {
        todayCounts.reduce(0) { $0 + $1.key * $1.value }
    }

    // MARK: - Private

    private func reloadToday() async {
        todayCounts = await service.counts(for: Date())
    }

    private func reloadWeek() async {
        let totals = await service.weekTotals(weekOf: Date())
        var bars = Array(repeating: 0, count: 7)
        for (date, total) in totals {
            let idx = (calendar.component(.weekday, from: date) + 5) % 7 // Пн=0 ... Вс=6
            bars[idx] = total
        }
        weekBars = bars
    }

    private func syncAppStorage() {
        storedGoalML  = goalML
        storedTodayML = todayTotalML
    }
}
