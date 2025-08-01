//
//  TimerView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//
import SwiftUI

struct TimerView: View {
    @EnvironmentObject var store: WorkoutStore
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Workout type", selection: $viewModel.workoutType) {
                    ForEach(WorkoutType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Spacer()
                
                CircleTimerView(
                    progress: min(viewModel.elasped / 3600, 1),
                    time: Int(viewModel.elasped)
                )
                
                Spacer()
                
                TextField("Notes", text: $viewModel.notes)
                    .textFieldStyle(.roundedBorder)
                
                HStack(spacing: 12) {
                    AppButton(
                        title: "Старт", //viewModel.isRunning ? "Старт" : (viewModel.elasped > 0 ? "Продолжить" : "Старт"),
                        color: viewModel.isRunning ? .gray : .green,
                        isDisabled: viewModel.isRunning
                    ) {
                        viewModel.start()
                    }

                    AppButton(
                        title: "Пауза",
                        color: viewModel.isRunning ? .yellow : .gray,
                        isDisabled: !viewModel.isRunning
                    ) {
                        viewModel.pause()
                    }

                    AppButton(
                        title: "Стоп",
                        color: .red
                    ) {
                        viewModel.stop(store: store)
                    }
                }
                .frame(height: 44)
                
                Spacer()
            }
            .mainBackground()
            .navigationTitle("Таймер")
            .hideKeyboard()
        }
    }
}
