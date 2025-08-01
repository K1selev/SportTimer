//
//  ManualEntryView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 31.07.2025.
//

import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: WorkoutStore

    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var durationInMinutes = 30
    @State private var workoutType: WorkoutType = .other
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var showSuccessMessage = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    Picker("Тип тренировки", selection: $workoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Дата и время тренировки")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)

                            DatePicker("Время начала", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                        }
                    }

                    Stepper(value: $durationInMinutes, in: 1...300) {
                        Text("Продолжительность: \(durationInMinutes) мин")
                    }

                    TextField("Заметки", text: $notes)
                        .textFieldStyle(.roundedBorder)

                    if isSaving {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        AppButton(title: "Сохранить", color: .green) {
                            saveWorkout()
                        }
                    }

                    Spacer(minLength: 40)
                }
                .mainBackground()
                .navigationTitle("Добавить")
                .hideKeyboard()

                // ✅ Уведомление об успехе
                if showSuccessMessage {
                    VStack {
                        Spacer()
                        Text("Сохранено успешно!")
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 6)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 40)
                    }
                    .animation(.easeOut(duration: 0.3), value: showSuccessMessage)
                }
            }
        }
    }

    private func saveWorkout() {
        isSaving = true

        let calendar = Calendar.current
        let dateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? Date()

        Task {
            await store.addWorkout(
                type: workoutType.rawValue,
                duration: durationInMinutes * 60,
                date: dateTime,
                notes: notes
            )

            await MainActor.run {
                resetFields()
                isSaving = false
                showSuccess()
            }
        }
    }

    private func resetFields() {
        selectedDate = Date()
        selectedTime = Date()
        durationInMinutes = 30
        workoutType = .other
        notes = ""
    }

    private func showSuccess() {
        withAnimation {
            showSuccessMessage = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showSuccessMessage = false
                dismiss()
            }
        }
    }
}
