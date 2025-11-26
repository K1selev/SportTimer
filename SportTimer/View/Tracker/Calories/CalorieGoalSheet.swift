//
//  CalorieGoalSheet.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.
//

import SwiftUI

struct CalorieGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CalorieGoalVM()
    var onSetGoal: (Int) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                // Вводные (как у воды)
                SectionCard {
                    rowPicker(title: "Пол", value: vm.gender?.rawValueRu ?? "—")
                        .onTapGesture { withAnimation { vm.toggleGender() } }
                    divider
                    rowPicker(title: "Активность", value: vm.activity.rawValueRu)
                        .onTapGesture { withAnimation { vm.cycleActivity() } }
                }

                SectionCard {
                    iconTextField(system: "number", placeholder: "Возраст", text: $vm.age, suffix: "лет")
                    divider
                    iconTextField(system: "scalemass", placeholder: "Вес", text: $vm.weight, suffix: "кг")
                    divider
                    iconTextField(system: "ruler", placeholder: "Рост", text: $vm.height, suffix: "см")
                }

                SectionCard {
                    HStack {
                        Text("Цель")
                        Spacer()
                        Picker("", selection: $vm.goalType) {
                            ForEach(CalorieGoalVM.Goal.allCases, id: \.self) { g in
                                Text(g.title).tag(g)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .frame(height: 48)
                }

                Button("Рассчитать") {
                    vm.calculate()
                    UIApplication.shared.dismissKeyboard()
                }
                    .buttonStyle(PrimaryGradientButtonStyle())
                    .disabled(!vm.canCalculate)

                if let kcal = vm.resultKcal {
                    SectionCard {
                        VStack(spacing: 8) {
                            Text("\(kcal) ккал")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    Button("Установить как цель") {
                        onSetGoal(kcal)
                        dismiss()
                    }
                    .buttonStyle(PrimaryGradientButtonStyle())
                }

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 16)
            .navigationTitle("Цель по калориям")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }

    private func rowPicker(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
            Image(systemName: "chevron.down").foregroundStyle(.secondary)
        }
        .frame(height: 48)
    }

    private func iconTextField(system: String, placeholder: String, text: Binding<String>, suffix: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: system).foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .keyboardType(.numberPad)
            Text(suffix)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.06))
                .clipShape(Capsule())
                .foregroundStyle(.secondary)
        }
        .frame(height: 48)
    }

    private var divider: some View {
        Rectangle().fill(Color.black.opacity(0.06)).frame(height: 1)
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
