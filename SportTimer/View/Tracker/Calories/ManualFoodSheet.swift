//
//  ManualFoodSheet.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.
//

import SwiftUI

struct ManualFoodSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (FoodEntry) -> Void

    @State private var name = ""
    @State private var servingSize = 100.0
    @State private var servingUnit = "г"
    @State private var calories = 0.0
    @State private var protein = 0.0
    @State private var fat = 0.0
    @State private var carbs = 0.0
    @State private var qty = 1.0

    private let units = ["г", "мл", "порция"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Блюдо") {
                    TextField("Название", text: $name)
                    HStack {
                        Text("Порция")
                        Spacer()
                        TextField("100", value: $servingSize, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Picker("", selection: $servingUnit) {
                            ForEach(units, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 90)
                    }
                    Stepper(value: $qty, in: 0.25...10, step: 0.25) {
                        Text("Количество: ×\(String(format: "%.2g", qty))")
                    }
                }

                Section("Калории / БЖУ на указанную порцию") {
                    HStack {
                        Text("Калории, ккал")
                        Spacer()
                        TextField("0", value: $calories, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Белки, г")
                        Spacer()
                        TextField("0", value: $protein, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Жиры, г")
                        Spacer()
                        TextField("0", value: $fat, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Углеводы, г")
                        Spacer()
                        TextField("0", value: $carbs, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    Button("Рассчитать ккал из БЖУ") {
                        calories = protein*4 + fat*9 + carbs*4
                    }
                }
            }
            .navigationTitle("Добавить блюдо")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let facts = NutritionFacts(
                            calories: calories,
                            protein: protein,
                            fat: fat,
                            carbs: carbs,
                            servingSize: servingSize,
                            servingUnit: servingUnit
                        )
                        onSave(FoodEntry(name: name.isEmpty ? "Блюдо" : name, quantity: qty, facts: facts))
                        dismiss()
                    }
                    .disabled(calories <= 0 && (protein+fat+carbs) <= 0)
                }
            }
        }
    }
}
