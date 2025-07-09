//
//  CoreDataManager.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "SportTimer")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error.localizedDescription)")
            }
        }
    }

    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
