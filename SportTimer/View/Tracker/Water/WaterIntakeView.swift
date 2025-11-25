//
//  WaterIntakeView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import SwiftUI

struct WaterIntakeView: View {
    @StateObject private var vm = WaterIntakeVM()
    @State private var showCalcSheet = false
    @State private var showCustomCup = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerToday
                statsSection
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .background(WaterTheme.bg.ignoresSafeArea())
            .navigationTitle("Баланс воды")
            .task { await vm.onAppear() }
            .sheet(isPresented: $showCalcSheet) {
                WaterCalculatorSheet(
                    onResult: { _ in },
                    onSetGoal: { ml in
                        Task { await vm.setGoal(ml) }
                    }
                )
            }
            .sheet(isPresented: $showCustomCup) {
                CustomCupSheet { ml in
                    vm.addCustomCup(ml: ml)
                }
            }
        }
    }

    // MARK: - Sections

    private var headerToday: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Сегодня")
                    .font(.headline)
                Spacer()
                let liters = Double(vm.goalML) / 1000.0
                Text("Цель: \(liters.formatted(.number.precision(.fractionLength(1)))) л")
                    .foregroundStyle(WaterTheme.textSecondary)
                    .font(.subheadline)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    CupAddTile { showCustomCup = true }

                    ForEach(vm.cups, id: \.self) { cupML in
                        let count = vm.todayCounts[cupML] ?? 0
                        CupCounterView(
                            ml: cupML,
                            count: count,
                            onIncrement: { Task { await vm.increment(cupML) } },
                            onDecrement: { Task { await vm.decrement(cupML) } },
                            onRemove:    { vm.removeCup(cupML) }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }

            Button { showCalcSheet = true } label: {
                Text("Изменить цель")
            }
            .buttonStyle(PrimaryGradientButtonStyle())
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Статистика")
                .font(.headline)

            WaterBarChart(valuesML: vm.weekBars, goalML: vm.goalML)
                .frame(height: 180)
        }
    }
}
