//
//  StepsRepository.swift
//  SportTimer
//
//  Created by Сергей Киселев on 24.11.2025.
//

import Foundation
import SwiftUI

@MainActor
final class StepsRepository: ObservableObject {
    @Published var weekSteps: [HealthKitClient.DaySteps] = []
    private let hk = HealthKitClient.shared
    private let cal = Calendar.current

    var weekRange: (Date, Date) {
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -6, to: today)!
        return (start, cal.date(byAdding: .day, value: 1, to: today)!)
    }

    func loadWeek() async {
        let (start, end) = weekRange
        do { weekSteps = try await hk.fetchStepsByDay(start: start, end: end) }
        catch { weekSteps = [] }
    }

    var todaySteps: Int {
        let today = cal.startOfDay(for: Date())
        return weekSteps.first(where: { cal.isDate($0.date, inSameDayAs: today) })?.steps ?? 0
    }
}
