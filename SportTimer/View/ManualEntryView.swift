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
    @State private var showTimer = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    GradientSegmentedPicker(
                                            options: WorkoutType.allCases,
                                            title: { $0.rawValue },
                                            selection: $workoutType
                                        )
                                        .padding(.top, 8)
                    
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
                        Button {
                            saveWorkout()
                        } label: { Text("Сохранить") }
                        .buttonStyle(PrimaryGradientButtonStyle())
                    }
                    
                    Spacer(minLength: 40)
                }
                .mainBackground()
                .navigationTitle("Тренировка")
                .hideKeyboard()
                
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
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showTimer = true
                        } label: {
                            Image(systemName: "timer")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(
                                    Circle().fill(AppTheme.gradient) // <- тот же градиент
                                )
                        }
                        .accessibilityLabel("Открыть таймер")
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
                .allowsHitTesting(true) //
            }
            .fullScreenCover(isPresented: $showTimer) {
                TimerView()
                    .environmentObject(store)
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
//                dismiss()
            }
        }
    }
}
