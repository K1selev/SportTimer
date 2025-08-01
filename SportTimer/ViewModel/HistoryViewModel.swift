//
//  HistoryViewModel.swift
//  SportTimer
//
//  Created by Алексей Авер on 09.07.2025.
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var allWorkouts: [Workout] = []
    @Published var filteredWorkouts: [Workout] = []
    @Published var searchQuery = ""
    @Published var dateFilter: Date? = nil
    
    private var store: WorkoutStore
    private var cancellables = Set<AnyCancellable>()
    
    init(store: WorkoutStore) {
        self.store = store
        allWorkouts = store.workouts
        filteredWorkouts = allWorkouts
        
        store.$workouts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] upd in
                self?.allWorkouts = upd
                self?.applyFilters(query: self?.searchQuery ?? "", date: self?.dateFilter)
            }
            .store(in: &cancellables)
        
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .combineLatest($dateFilter)
            .sink { [weak self] query, date in
                self?.applyFilters(query: query, date: date)
            }
            .store(in: &cancellables)
    }
    
    func applyFilters(query: String, date: Date?) {
        filteredWorkouts = allWorkouts.filter { workout in
            let matchText = query.isEmpty ||
            workout.type.lowercased().contains(query.lowercased()) ||
            (workout.notes ?? "").lowercased().contains(query.lowercased())
            
            let matchDate = date == nil ||
            Calendar.current.isDate(workout.date, inSameDayAs: date!)
            
            return matchText && matchDate
        }
    }
    
    var grouped: [Date: [Workout]] {
        Dictionary(grouping: filteredWorkouts) { workout in
            Calendar.current.startOfDay(for: workout.date)
        }
    }
    
    func delete(_ workout: Workout) {
        store.deleteWorkout(workout)
        allWorkouts = store.workouts
        applyFilters(query: searchQuery, date: dateFilter)
    }
}
