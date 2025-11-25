//
//  HealthKitClient.swift
//  SportTimer
//
//  Created by Сергей Киселев on 24.11.2025.
//

import Foundation
import HealthKit

final class HealthKitClient {
    static let shared = HealthKitClient()
    private let store = HKHealthStore()

    private init() {}

    // MARK: Auth
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!

        try await store.requestAuthorization(toShare: [], read: [sleepType, stepsType])
    }

    // MARK: Sleep (minutes “inBed” per day)
    struct DaySleep: Identifiable {
        let id = UUID()
        let date: Date       // полночь дня
        let minutes: Int     // суммарно за день
    }

    /// Возвращает сон по дням в указанном диапазоне [start...end)
    func fetchSleepByDay(start: Date, end: Date) async throws -> [DaySleep] {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { cont in
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: nil) { [weak self] _, samples, error in
                if let error { cont.resume(throwing: error); return }
                guard let samples = samples as? [HKCategorySample], let self else {
                    cont.resume(returning: [])
                    return
                }

                // группируем по календарным дням
                var bucket: [Date: Int] = [:]
                let cal = Calendar.current

                for s in samples {
                    // оставим все фазы сна, как делает «Здоровье» в сводке «В постели»
                    let clampedStart = max(s.startDate, start)
                    let clampedEnd   = min(s.endDate, end)
                    guard clampedEnd > clampedStart else { continue }

                    // разрезаем по дням
                    var cursor = clampedStart
                    while cursor < clampedEnd {
                        let dayStart = cal.startOfDay(for: cursor)
                        let dayEnd   = cal.date(byAdding: .day, value: 1, to: dayStart)!
                        let segmentEnd = min(dayEnd, clampedEnd)
                        let minutes = Int(segmentEnd.timeIntervalSince(cursor) / 60.0)

                        bucket[dayStart, default: 0] += max(0, minutes)
                        cursor = segmentEnd
                    }
                }

                // заполняем нулями отсутствующие дни
                var result: [DaySleep] = []
                var d = Calendar.current.startOfDay(for: start)
                while d < end {
                    result.append(DaySleep(date: d, minutes: bucket[d, default: 0]))
                    d = cal.date(byAdding: .day, value: 1, to: d)!
                }

                cont.resume(returning: result)
            }
            self.store.execute(query)
        }
    }

    // MARK: Steps (per day)
    struct DaySteps: Identifiable {
        let id = UUID()
        let date: Date
        let steps: Int
    }

    func fetchStepsByDay(start: Date, end: Date) async throws -> [DaySteps] {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let interval = DateComponents(day: 1)

        return try await withCheckedThrowingContinuation { cont in
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: [.cumulativeSum],
                anchorDate: Calendar.current.startOfDay(for: start),
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, collection, error in
                if let error { cont.resume(throwing: error); return }
                guard let collection else { cont.resume(returning: []); return }

                var arr: [DaySteps] = []
                collection.enumerateStatistics(from: start, to: end) { stats, _ in
                    let steps = Int(stats.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                    arr.append(DaySteps(date: stats.startDate, steps: steps))
                }
                cont.resume(returning: arr)
            }
            self.store.execute(query)
        }
    }
}
