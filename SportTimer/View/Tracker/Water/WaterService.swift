//
//  WaterService.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//



import Foundation

protocol WaterServiceProtocol {
    func loadGoal() async -> Int
    func saveGoal(_ ml: Int) async

    func counts(for date: Date) async -> [Int: Int]
    func setCount(_ count: Int, for cupML: Int, on date: Date) async
    func increment(cupML: Int, on date: Date) async
    func decrement(cupML: Int, on date: Date) async

    func weekTotals(weekOf date: Date) async -> [Date: Int]
}

final class UserDefaultsWaterService: WaterServiceProtocol {
    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    private let countsKey = "water.counts.by.date"
    private let goalKey   = "water.goal.ml"

    private func dayKey(_ date: Date) -> String {
        let comp = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comp.year ?? 0, comp.month ?? 0, comp.day ?? 0)
    }

    func loadGoal() async -> Int {
        defaults.integer(forKey: goalKey) == 0 ? 2000 : defaults.integer(forKey: goalKey)
    }

    func saveGoal(_ ml: Int) async {
        defaults.set(ml, forKey: goalKey)
    }

    func counts(for date: Date) async -> [Int : Int] {
        let dict = defaults.dictionary(forKey: countsKey) as? [String: [String:Int]] ?? [:]
        let day = dayKey(date)
        let raw = dict[day] ?? [:]
        var out: [Int:Int] = [:]
        raw.forEach { k, v in out[Int(k) ?? 0] = v }
        return out
    }

    func setCount(_ count: Int, for cupML: Int, on date: Date) async {
        var dict = defaults.dictionary(forKey: countsKey) as? [String: [String:Int]] ?? [:]
        let day = dayKey(date)
        var inner = dict[day] ?? [:]
        if count <= 0 {
            inner.removeValue(forKey: "\(cupML)")
        } else {
            inner["\(cupML)"] = count
        }
        dict[day] = inner.isEmpty ? nil : inner
        defaults.set(dict, forKey: countsKey)
    }

    func increment(cupML: Int, on date: Date) async {
        var c = await counts(for: date)
        c[cupML] = (c[cupML] ?? 0) + 1
        await setCount(c[cupML] ?? 0, for: cupML, on: date)
    }

    func decrement(cupML: Int, on date: Date) async {
        var c = await counts(for: date)
        let new = max(0, (c[cupML] ?? 0) - 1)
        await setCount(new, for: cupML, on: date)
    }

    func weekTotals(weekOf date: Date) async -> [Date : Int] {
        let start = calendar.dateInterval(of: .weekOfYear, for: date)!.start
        var result: [Date:Int] = [:]
        for i in 0..<7 {
            let d = calendar.date(byAdding: .day, value: i, to: start)!
            let c = await counts(for: d)
            let sum = c.reduce(0) { $0 + $1.key * $1.value }
            result[d] = sum
        }
        return result
    }
}
