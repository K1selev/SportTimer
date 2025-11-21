//
//  WorkoutComposeView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 02.10.2025.
//

import SwiftUI

struct WorkoutComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: WorkoutStore
    @StateObject private var timerVM = TimerViewModel()

    // Переключатель режимов
    enum Mode: String, CaseIterable { case timer = "Таймер", manual = "Вручную" }
    @State private var mode: Mode = .timer

    // Поля для ручного ввода (взяты из ManualEntryView)
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var durationInMinutes = 30
    @State private var manualType: WorkoutType = .other
    @State private var manualNotes: String = ""
    @State private var isSaving = false
    @State private var showSuccessMessage = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Шапка в духе экрана авторизации
                        header

                        // Переключатель режимов
                        Picker("Режим", selection: $mode) {
                            ForEach(Mode.allCases, id: \.self) { m in
                                Text(m.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)

                        // Контент по режиму
                        Group {
                            if mode == .timer {
                                timerCard
                                notesCard(text: $timerVM.notes)
                                timerControls
                            } else {
                                manualCard
                                notesCard(text: $manualNotes)
                                saveManualButton
                            }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .mainBackground()
                .navigationTitle("Тренировка")
                .navigationBarTitleDisplayMode(.inline)
                .hideKeyboard()

                // Тост «Сохранено»
                if showSuccessMessage {
                    toastSuccess
                }
            }
        }
    }
}

// MARK: - Subviews

private extension WorkoutComposeView {

    var header: some View {
        VStack(spacing: 6) {
            Text("Hey there,")
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(mode == .timer ? "Start your Workout" : "Add a Workout")
                .font(.system(.title, design: .rounded).bold())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // Карточка таймера
    var timerCard: some View {
        VStack(spacing: 16) {
            // Тип тренировки
            VStack(alignment: .leading, spacing: 8) {
                Text("Тип тренировки")
                    .font(.caption).foregroundColor(.secondary)
                Picker("Тип тренировки", selection: $timerVM.workoutType) {
                    ForEach(WorkoutType.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)
            }

            // Сам круглый таймер
            VStack(spacing: 12) {
                CircleTimerView(
                    progress: min(timerVM.elasped / 3600, 1),
                    time: Int(timerVM.elasped)
                )
                Text(timerTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .cardStyle()
    }

    var timerControls: some View {
        HStack(spacing: 12) {
            AppButton(
                title: "Старт",
                color: timerVM.isRunning ? .gray : .green,
                isDisabled: timerVM.isRunning
            ) { timerVM.start() }

            AppButton(
                title: "Пауза",
                color: timerVM.isRunning ? .yellow : .gray,
                isDisabled: !timerVM.isRunning
            ) { timerVM.pause() }

            AppButton(
                title: "Стоп",
                color: .red
            ) { timerVM.stop(store: store) }
        }
        .frame(height: 44)
    }

    // Карточка ручного ввода
    var manualCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Тип тренировки
            VStack(alignment: .leading, spacing: 8) {
                Text("Тип тренировки")
                    .font(.caption).foregroundColor(.secondary)
                Picker("Тип тренировки", selection: $manualType) {
                    ForEach(WorkoutType.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)
            }

            // Дата и время
            VStack(alignment: .leading, spacing: 8) {
                Text("Дата и время")
                    .font(.caption).foregroundColor(.secondary)

                HStack {
                    DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                    Spacer(minLength: 12)
                    DatePicker("Время", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }

            // Длительность
            VStack(alignment: .leading, spacing: 8) {
                Text("Длительность")
                    .font(.caption).foregroundColor(.secondary)
                Stepper(value: $durationInMinutes, in: 1...300) {
                    Text("\(durationInMinutes) мин")
                        .font(.body)
                }
            }
        }
        .cardStyle()
    }

    // Карточка заметок (общая для обоих режимов)
    func notesCard(text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Заметки")
                .font(.caption).foregroundColor(.secondary)
            TextField("Добавьте комментарий…", text: text)
                .textFieldStyle(.roundedBorder)
        }
        .cardStyle()
    }

    // Кнопка сохранения для ручного режима
    var saveManualButton: some View {
        Group {
            if isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                AppButton(title: "Сохранить", color: .green) {
                    saveManual()
                }
            }
        }
    }

    var toastSuccess: some View {
        VStack {
            Spacer()
            Text("Сохранено успешно!")
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color.green.opacity(0.95))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 40)
        }
        .animation(.easeOut(duration: 0.3), value: showSuccessMessage)
        .allowsHitTesting(false)
    }
}

// MARK: - Helpers & Styles

private extension WorkoutComposeView {
    var timerTitle: String {
        if timerVM.isRunning { return "Идёт тренировка…" }
        if timerVM.elasped > 0 { return "Пауза" }
        return "Готов к старту"
    }

    func saveManual() {
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
                type: manualType.rawValue,
                duration: durationInMinutes * 60,
                date: dateTime,
                notes: manualNotes
            )

            await MainActor.run {
                resetManualFields()
                isSaving = false
                showSuccess()
            }
        }
    }

    func resetManualFields() {
        selectedDate = Date()
        selectedTime = Date()
        durationInMinutes = 30
        manualType = .other
        manualNotes = ""
    }

    func showSuccess() {
        withAnimation { showSuccessMessage = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showSuccessMessage = false }
            dismiss()
        }
    }
}

private extension View {
    /// карточный контейнер под общий стиль (похоже на дизайн авторизации)
    func cardStyle() -> some View {
        self
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
