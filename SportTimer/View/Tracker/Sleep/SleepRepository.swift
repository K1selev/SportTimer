//
//  SleepRepository.swift
//  SportTimer
//
//  Created by Сергей Киселев on 24.11.2025.
//


import Foundation
import SwiftUI

@MainActor
final class SleepRepository: ObservableObject {
    @Published var weekSleep: [HealthKitClient.DaySleep] = []
    @Published var isAuthorized = false
    @Published var loading = false
    @Published var error: String?

    private let hk = HealthKitClient.shared
    private let cal = Calendar.current

    var weekRange: (start: Date, end: Date) {
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -6, to: today)! // последние 7 дней
        return (start, cal.date(byAdding: .day, value: 1, to: today)!)
    }

    func authorizeIfNeeded() async {
        do {
            try await hk.requestAuthorization()
            isAuthorized = true
        } catch {
            self.error = error.localizedDescription
            isAuthorized = false
        }
    }

    func loadWeek() async {
        loading = true; defer { loading = false }
        do {
            let r = weekRange
            weekSleep = try await hk.fetchSleepByDay(start: r.start, end: r.end)
        } catch {
            self.error = error.localizedDescription
            weekSleep = []
        }
    }

    var averageMinutes: Int {
        guard !weekSleep.isEmpty else { return 0 }
        let sum = weekSleep.map(\.minutes).reduce(0, +)
        return sum / weekSleep.count
    }
}
