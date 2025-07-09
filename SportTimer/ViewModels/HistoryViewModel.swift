//
//  HistoryViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import Foundation
import CoreData
import Combine
import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedType: String = "All"
    
    let workoutTypes = ["All", "Strength", "Cardio", "Yoga", "Stretching", "Other"]
    
    func filteredWorkouts(from workouts: FetchedResults<Workout>) -> [Workout] {
        workouts.filter { workout in
            (selectedType == "All" || workout.type == selectedType) &&
            (searchText.isEmpty || workout.notes?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }
    
    func deleteWorkout(_ workout: Workout, from context: NSManagedObjectContext) {
        context.delete(workout)
        do {
            try context.save()
        } catch {
            print("Ошибка при удалении: \(error.localizedDescription)")
        }
    }
}
