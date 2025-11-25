//
//  HealthKitManager.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.
//

import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private init() {}

    // Разрешения
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let read: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        try await store.requestAuthorization(toShare: [], read: read)
    }

    // MARK: - Шаги

    /// Сумма шагов за сегодня
    func todaySteps() async throws -> Int {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let (start, end) = Self.dayBounds(Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { cont in
            let stat = HKStatisticsQuery(quantityType: type,
                                         quantitySamplePredicate: predicate,
                                         options: .cumulativeSum) { _, result, error in
                if let error = error { return cont.resume(throwing: error) }
                let sum = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                cont.resume(returning: Int(sum))
            }
            self.store.execute(stat)
        }
    }

    /// Массив по дням: последние 7 дней (включая сегодня)
    func last7DaysSteps() async throws -> [Int] {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: Date()).addingTimeInterval(24*60*60)
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date()))!

        let anchor = calendar.startOfDay(for: start)
        var interval = DateComponents()
        interval.day = 1

        return try await withCheckedThrowingContinuation { cont in
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate),
                options: .cumulativeSum,
                anchorDate: anchor,
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, collection, error in
                if let error = error { return cont.resume(throwing: error) }
                var out: [Int] = []
                collection?.enumerateStatistics(from: start, to: end) { stats, _ in
                    let sum = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    out.append(Int(sum))
                }
                cont.resume(returning: out)
            }
            self.store.execute(query)
        }
    }

    // MARK: - Сон

    /// Минуты сна за сегодня (по умолчанию — только «asleep»; можно включить «inBed», см. флаг)
    func todaySleepMinutes(includeInBed: Bool = false) async throws -> Int {
        let category = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let (start, end) = Self.dayBounds(Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(sampleType: category, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error { return cont.resume(throwing: error) }
                let minutes = Self.minutes(from: samples as? [HKCategorySample] ?? [], includeInBed: includeInBed)
                cont.resume(returning: minutes)
            }
            self.store.execute(query)
        }
    }

    /// Минуты сна по дням за последние 7 дней
    func last7DaysSleepMinutes(includeInBed: Bool = false) async throws -> [Int] {
        let category = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date()))!
        let end = calendar.startOfDay(for: Date()).addingTimeInterval(24*60*60)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { cont in
            let q = HKSampleQuery(sampleType: category, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error { return cont.resume(throwing: error) }

                var byDay: [Date: Int] = [:]
                let cal = Calendar.current
                let grouped = Dictionary(grouping: (samples as? [HKCategorySample] ?? [])) {
                    cal.startOfDay(for: $0.startDate)
                }
                for (day, list) in grouped {
                    byDay[day] = Self.minutes(from: list, includeInBed: includeInBed)
                }

                var out: [Int] = []
                for i in 0..<7 {
                    let d = cal.date(byAdding: .day, value: i, to: cal.startOfDay(for: start))!
                    out.append(byDay[d] ?? 0)
                }
                cont.resume(returning: out)
            }
            self.store.execute(q)
        }
    }

    // MARK: - Utils

    private static func minutes(from samples: [HKCategorySample], includeInBed: Bool) -> Int {
        var total: TimeInterval = 0
        for s in samples {
            // Берём только sleep stages "asleep" (и опционально "inBed")
            let v = HKCategoryValueSleepAnalysis(rawValue: s.value) ?? .inBed
            let shouldInclude: Bool = {
                switch v {
                case .asleep, .asleepCore, .asleepDeep, .asleepREM: return true
                case .inBed: return includeInBed
                default: return false
                }
            }()
            if shouldInclude {
                total += s.endDate.timeIntervalSince(s.startDate)
            }
        }
        return Int(total / 60.0)
    }

    private static func dayBounds(_ date: Date) -> (Date, Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        return (start, cal.date(byAdding: .day, value: 1, to: start)!)
    }
}
