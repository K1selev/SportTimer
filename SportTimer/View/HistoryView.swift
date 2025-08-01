//
//  HistoryView.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: WorkoutStore
    @StateObject private var viewModel: HistoryViewModel
    
    init(store: WorkoutStore) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(store: store))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $viewModel.searchQuery)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                DatePicker("Дата", selection: Binding(
                    get: { viewModel.dateFilter ?? Date() },
                    set: { viewModel.dateFilter = $0 }
                ), displayedComponents: .date)
                .padding(.horizontal)
                
                List {
                    ForEach(viewModel.filteredWorkouts) { workout in
                        WorkoutCardView(workout: workout)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.delete(workout)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .mainBackground()
            .navigationTitle("История")
        }
    }
}
