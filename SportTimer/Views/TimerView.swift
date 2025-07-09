//
//  TimerView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var viewModel = TimerViewModel()
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.duration % 60) / 60)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                    .animation(.easeInOut, value: viewModel.duration)

                Text(formatTime(viewModel.duration))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
            }

            // MARK: - Workout Type Picker
            Picker("Тип тренировки", selection: $viewModel.selectedType) {
                ForEach(viewModel.workoutTypes, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)

            // MARK: - Notes
            TextField("Заметки...", text: $viewModel.notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // MARK: - Timer Buttons
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.isRunning ? viewModel.pauseTimer() : viewModel.startTimer()
                }) {
                    Text(viewModel.isRunning ? "Пауза" : "Старт")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(viewModel.isRunning ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    viewModel.stopTimer(context: context)
                }) {
                    Text("Стоп")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Тренировка")
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    func formatTime(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60

        return hrs > 0
            ? String(format: "%02d:%02d:%02d", hrs, mins, secs)
            : String(format: "%02d:%02d", mins, secs)
    }
}
