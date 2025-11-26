//
//  TrackerView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 24.11.2025.
//

import SwiftUI

struct TrackerView: View {
    @StateObject private var vm = TrackerVM()
    @State private var stepsWeek: [Double] = []
    @State private var sleepWeek: [Double] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    let hm = sleepHM(vm.sleepTodayMin)
                    HealthSummaryCard(
                        title: "Сон",
                        icon: Image(systemName: "bed.double.fill"),
                        tint: Color(red: 146/255, green: 163/255, blue: 253/255),
                        bigValue: "\(hm.h) ч \(hm.m)",
                        unit: "мин",
                        dateLine: dateLineNow(),
                        bars: sleepWeek.isEmpty ? [430, 410, 415, 390, 405, 345, Double(vm.sleepTodayMin)]
                                                : sleepWeek
                    )
                    HealthSummaryCard(
                        title: "Шаги",
                        icon: Image(systemName: "flame.fill"),
                        tint: Color(red: 197/255, green: 139/255, blue: 242/255),
                        bigValue: vm.stepsToday.grouped,
                        unit: "шагов",
                        dateLine: timeShortNow(),
                        bars: stepsWeek.isEmpty ? [1200, 5400, 2100, 4800, 9200, 9650, Double(vm.stepsToday)]
                                                : stepsWeek
                    )
                    NavigationLink {
                        WaterIntakeView()
                    } label: {
                        let goalL = Double(vm.waterGoalML) / 1000.0
                        TrackerCard(
                            icon: Image("glass"),
                            titleValue: String(format: "%.1f L", goalL),
                            subtitle: "Водный баланс",
                            progress: vm.waterProgress,
                            tappable: true
                        )
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        CalorieCounterView()
                    } label: {
                        TrackerCard(
                            icon: Image("nutrition"),
                            titleValue: "\(vm.kcalGoal) cal",
                            subtitle: "Питание",
                            progress: vm.kcalProgress,
                            tappable: true
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .navigationTitle("Трекер")
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .task { await syncFromHealthKit() }
    }

    @MainActor
    private func syncFromHealthKit() async {
        do {
            try await HealthKitManager.shared.requestAuthorization()

            async let todaySteps = HealthKitManager.shared.todaySteps()
            async let last7Steps = HealthKitManager.shared.last7DaysSteps()
            async let todaySleep = HealthKitManager.shared.todaySleepMinutes()
            async let last7Sleep = HealthKitManager.shared.last7DaysSleepMinutes()

            let (sToday, s7, slToday, sl7) = try await (todaySteps, last7Steps, todaySleep, last7Sleep)

            vm.stepsToday = sToday
            vm.sleepTodayMin = slToday
            stepsWeek = s7.map(Double.init)
            sleepWeek = sl7.map(Double.init)
        } catch {
            print("HealthKit authorization or fetch failed: \(error)")
        }
    }
}

private struct SparklineBars: View {
    let values: [Double]
    let maxHeight: CGFloat = 42
    let barWidth: CGFloat = 6
    let barCorner: CGFloat = 3

    var body: some View {
        let maxVal = max(values.max() ?? 1, 1)
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(values.indices, id: \.self) { i in
                let h = CGFloat(values[i] / maxVal) * maxHeight
                RoundedRectangle(cornerRadius: barCorner, style: .continuous)
                    .fill(Color(.systemGray4))
                    .frame(width: barWidth, height: max(h, 4))
            }
        }
    }
}

private struct HealthSummaryCard: View {
    let title: String
    let icon: Image
    let tint: Color
    let bigValue: String
    let unit: String?
    let dateLine: String
    let bars: [Double]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.secondarySystemBackground),
                            Color(.secondarySystemBackground).opacity(0.95)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(tint)
                            .padding(6)
                            .background(Circle().fill(tint.opacity(0.12)))

                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer(minLength: 6)

                        Text(dateLine)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(bigValue)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)

                        if let unit {
                            Text(unit)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    HStack { Spacer(); SparklineBars(values: bars) }
                }
            }
            .padding(16)
        }
    }
}

private extension Int {
    var grouped: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return f.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

private func sleepHM(_ minutes: Int) -> (h: Int, m: Int) { (minutes / 60, minutes % 60) }

private func dateLineNow() -> String {
    Date.now.formatted(date: .numeric, time: .shortened)
}

private func timeShortNow() -> String {
    let f = DateFormatter()
    f.locale = .current
    f.timeStyle = .short
    f.dateStyle = .none
    return f.string(from: Date())
}
