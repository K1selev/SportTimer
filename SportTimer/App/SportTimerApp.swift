//
//  SportTimerApp.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//

import SwiftUI
import CoreData
import UserNotifications

@main
struct SportTimerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isAuthorized = true
    
    let container = NSPersistentContainer(name: "WorkoutModel")
    let store: WorkoutStore
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("error CoreData initializing: \(error)")
            }
        }
        store = WorkoutStore(context: container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthorized {
                    MainTabView()
                } else {
                    AuthRootView()
                }
            }
            .environment(\.managedObjectContext, container.viewContext)
            .environmentObject(store)
            .preferredColorScheme(.light)
            .onAppear {
                NotificationManager.requestPermissionIfNeeded()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
