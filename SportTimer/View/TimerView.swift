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
    @Environment(\.dismiss) private var dismiss
    
    let stopColor = Color(red: 197/255, green: 139/255, blue: 242/255)
    let pauseColor = Color(red: 250/255, green: 217/255, blue: 109/255)
    let accentColor   = Color(red: 146/255, green: 163/255, blue: 253/255)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                GradientSegmentedPicker(
                                        options: WorkoutType.allCases,
                                        title: { $0.rawValue },
                                        selection: $viewModel.workoutType
                                    )
                                    .padding(.top, 8)
                
                Spacer()
                
                CircleTimerView(
                    progress: min(viewModel.elasped / 3600, 1),
                    time: Int(viewModel.elasped)
                )
                
                Spacer()
                
                TextField("Заметки", text: $viewModel.notes)
                    .textFieldStyle(.roundedBorder)
                
                HStack(spacing: 12) {
                    AppButton(
                        title: "Старт", //viewModel.isRunning ? "Старт" : (viewModel.elasped > 0 ? "Продолжить" : "Старт"),
                        color: viewModel.isRunning ? .gray : accentColor,
                        isDisabled: viewModel.isRunning
                    ) {
                        viewModel.start()
                    }
                    
                    AppButton(
                        title: "Пауза",
                        color: viewModel.isRunning ? pauseColor : .gray,
                        isDisabled: !viewModel.isRunning
                    ) {
                        viewModel.pause()
                    }
                    
                    AppButton(
                        title: "Стоп",
                        color: stopColor
                    ) {
                        viewModel.stop(store: store)
                    }
                }
                .frame(height: 44)
                
                Spacer()
            }
            .mainBackground()
            .navigationTitle("Таймер")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Назад", systemImage: "chevron.backward")
                    }
                }
            }
            // разрешаем жест свайпа-вниз при модальной подаче
            .interactiveDismissDisabled(false)
            .hideKeyboard()
        }
    }
}
