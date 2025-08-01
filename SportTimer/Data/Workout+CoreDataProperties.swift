//
//  Workout+CoreDataProperties.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
//

import Foundation
import CoreData

extension Workout: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var duration: Int32
    @NSManaged public var date: Date
    @NSManaged public var notes: String?
}

