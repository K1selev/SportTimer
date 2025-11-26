//
//  CalorieCounterView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.
//

import SwiftUI
import PhotosUI

private extension View {
    func gradientForeground() -> some View {
        overlay(
            LinearGradient(
                colors: [Color(red: 146/255, green: 163/255, blue: 253/255),
                         Color(red: 197/255, green: 139/255, blue: 242/255)],
                startPoint: .leading, endPoint: .trailing
            )
        ).mask(self)
    }
}

struct CalorieCounterView: View {
    @StateObject private var vm = CalorieCounterViewModel()
    @State private var photoItem: PhotosPickerItem?
    @State private var showKcalGoalSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                headerCard

                HStack(spacing: 12) {
                    Button {
                        vm.showManual = true
                    } label: {
                        Label("Добавить прием пищи", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryGradientButtonStyle())

//                    if #available(iOS 17.0, *) {
//                        PhotosPicker(selection: $photoItem, matching: .images) {
//                            Label("Сканировать", systemImage: "camera.viewfinder")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .onChange(of: photoItem) { _, newItem in
//                            Task {
//                                if let data = try? await newItem?.loadTransferable(type: Data.self),
//                                   let img = UIImage(data: data) {
//                                    vm.pickedImage = img
//                                    await vm.analyzePicked()
//                                }
//                            }
//                        }
//                    } else {
//                        // Fallback on earlier versions
//                    }
                }

                if vm.analyzing {
                    ProgressView("Распознаём…")
                        .progressViewStyle(.circular)
                }

                if let err = vm.errorText {
                    Text(err).foregroundStyle(.red).font(.footnote)
                }

                List {
                    ForEach(vm.entries) { entry in
                        FoodEntryRow(entry: entry) {
                            vm.update($0)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.delete(entry)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                        
                    }
                }
                .listStyle(.plain)
            }
            .padding(16)
            .navigationTitle("Питание")
            .sheet(isPresented: $vm.showManual) {
                ManualFoodSheet { entry in
                    vm.addManual(entry)
                }
            }
            .sheet(isPresented: $showKcalGoalSheet) {
                CalorieGoalSheet { newKcal in
                    vm.kcalGoal = newKcal
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Text("Итого за сегодня")
                .font(.subheadline).foregroundStyle(.secondary)

            Text("\(Int(vm.totalCalories)) ккал")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .gradientForeground()

            ProgressView(value: min(vm.totalCalories/Double(vm.kcalGoal), 1))
                .tint(LinearGradient(colors: [
                    Color(red: 146/255, green: 163/255, blue: 253/255),
                    Color(red: 197/255, green: 139/255, blue: 242/255)
                ], startPoint: .leading, endPoint: .trailing))
                .frame(height: 8)
                .clipShape(Capsule())

            Text("Цель: \(vm.kcalGoal) ккал")
                .font(.footnote).foregroundStyle(.secondary)
            Button {
                showKcalGoalSheet = true
            } label: {
                Text("Изменить цель")
            }
            .buttonStyle(PrimaryGradientButtonStyle())
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct FoodEntryRow: View {
    @State var entry: FoodEntry
    var onChange: (FoodEntry) -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let img = entry.photo {
                Image(uiImage: img).resizable().scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name).font(.headline)
                Text("\(Int(entry.facts.calories)) ккал • "
                     + "Б \(Int(entry.facts.protein)) • "
                     + "Ж \(Int(entry.facts.fat)) • "
                     + "У \(Int(entry.facts.carbs)) • "
                     + "\(Int(entry.facts.servingSize)) \(entry.facts.servingUnit)")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Stepper(value: Binding(
                get: { entry.quantity },
                set: { entry.quantity = $0; onChange(entry) }
            ), in: 0.25...10, step: 0.25) {
                Text("×\(String(format: "%.2g", entry.quantity))")
                    .font(.subheadline)
            }
            .frame(width: 120)
        }
        .padding(.vertical, 6)
    }
}
