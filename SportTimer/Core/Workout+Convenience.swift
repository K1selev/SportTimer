//
//  Workout+Convenience.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import Foundation
import CoreData

extension Workout {
    static func create(type: String, duration: Int, date: Date, notes: String?, context: NSManagedObjectContext) {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.type = type
        workout.duration = Int32(duration)
        workout.date = date
        workout.notes = notes
        try? context.save()
    }
}
