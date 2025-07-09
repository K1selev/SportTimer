//
//  SportTimerApp.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import SwiftUI

@main
struct SportTimerApp: App {
    let coreDataManager = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, coreDataManager.context)
        }
    }
}

