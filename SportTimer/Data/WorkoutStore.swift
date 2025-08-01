//
//  WorkoutStore.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
//


import Foundation
import CoreData

final class WorkoutStore: ObservableObject {
    private let context: NSManagedObjectContext

    @Published var workouts: [Workout] = []

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchWorkouts()
    }
    
    func fetchWorkouts() {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            workouts = try context.fetch(request)
        } catch {
            print("fetch err: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func addWorkout(type: String, duration: Int, date: Date, notes: String?) async {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.type = type
        workout.duration = Int32(duration)
        workout.date = date
        workout.notes = notes

        saveContext()
        fetchWorkouts()
    }

    @MainActor
    func deleteWorkout(_ workout: Workout) {
        context.delete(workout)
        saveContext()
        fetchWorkouts()
    }
    
    func deleteAllWorkouts() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            fetchWorkouts()
        } catch {
            print("Del err: \(error)")
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("save err: \(error.localizedDescription)")
            context.rollback()
        }
    }
}
