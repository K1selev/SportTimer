//
//  HistoryView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
    ) private var workouts: FetchedResults<Workout>
    
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Фильтр
                Picker("Тип", selection: $viewModel.selectedType) {
                    ForEach(viewModel.workoutTypes, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Поиск
                TextField("Поиск по заметкам...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // Список
                List {
                    ForEach(viewModel.filteredWorkouts(from: workouts), id: \.self) { workout in
                        VStack(alignment: .leading) {
                            Text(workout.type ?? "Unknown")
                                .font(.headline)
                            Text("Длительность: \(workout.duration) сек")
                            if let date = workout.date {
                                Text("Дата: \(date.formatted(date: .abbreviated, time: .shortened))")
                            }
                            if let notes = workout.notes, !notes.isEmpty {
                                Text("Заметки: \(notes)")
                                    .italic()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        let filtered = viewModel.filteredWorkouts(from: workouts)
                        indexSet.forEach { i in
                            viewModel.deleteWorkout(filtered[i], from: context)
                        }
                    }
                }
            }
            .navigationTitle("История тренировок")
        }
    }
}
