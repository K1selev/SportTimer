//
//  WaterCalculatorSheet.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//
//

import SwiftUI

struct WaterCalculatorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = WaterCalculatorVM()

    var onResult: (Int) -> Void
    var onSetGoal: (Int) -> Void

    @State private var showResult = false

    var body: some View {
        NavigationStack {
            Group {
                if showResult, let ml = vm.resultML {
                    resultView(ml: ml)
                } else {
                    formView
                }
            }
            .padding(.horizontal, 16)
            .navigationTitle("Калькулятор")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }

    // MARK: Форма ввода

    private var formView: some View {
        VStack(spacing: 14) {
            SectionCard {
                rowPicker(title: "Пол", value: vm.gender?.rawValueRu ?? "—")
                    .onTapGesture {
                        withAnimation {
                            vm.gender = (vm.gender == .male ? .female : .male)
                        }
                    }
                divider
                rowPicker(title: "Активность", value: vm.activity?.rawValueRu ?? "—")
                    .onTapGesture {
                        switch vm.activity {
                        case .none: vm.activity = .low
                        case .some(.low): vm.activity = .medium
                        case .some(.medium): vm.activity = .high
                        case .some(.high): vm.activity = .low
                        }
                    }
            }

            SectionCard {
                iconTextField(system: "number", placeholder: "Возраст", text: $vm.age, suffix: "лет")
                divider
                iconTextField(system: "scalemass", placeholder: "Вес", text: $vm.weight, suffix: "кг")
                divider
                iconTextField(system: "ruler", placeholder: "Рост", text: $vm.height, suffix: "см")
            }

            Button {
                vm.calculate()
                if let ml = vm.resultML {
                    onResult(ml)
                    withAnimation { showResult = true }
                }
            } label: {
                Text("Рассчитать")
            }
            .buttonStyle(PrimaryGradientButtonStyle())
            .disabled(!vm.canCalculate)

            Spacer(minLength: 20)
        }
    }

    // MARK: Результат

    private func resultView(ml: Int) -> some View {
        VStack(spacing: 16) {
            SectionCard {
                VStack(spacing: 8) {
                    Text(String(format: "%.1f л", Double(ml)/1000.0))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(WaterTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            Text("Рекомендованная дневная норма")
                .font(.headline)
            Text("Это примерно \(max(1, ml/250)) стаканов по 250 мл")
                .foregroundStyle(WaterTheme.textSecondary)
                .font(.footnote)
                .multilineTextAlignment(.center)

            Button {
                onSetGoal(ml)
                dismiss()
            } label: { Text("Установить как цель") }
            .buttonStyle(PrimaryGradientButtonStyle())

            Spacer()
        }
    }

    // MARK: Примитивы

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
            Image(systemName: system)
                .foregroundStyle(.secondary)
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

// MARK: Локализация enum-ов для калькулятора

private extension Gender {
    var rawValueRu: String { self == .male ? "Мужской" : "Женский" }
}

private extension ActivityLevel {
    var rawValueRu: String {
        switch self {
        case .low: return "Низкая"
        case .medium: return "Средняя"
        case .high: return "Высокая"
        }
    }
}

private struct SectionCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(spacing: 0, content: content)
            .padding(12)
            .background(WaterTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
