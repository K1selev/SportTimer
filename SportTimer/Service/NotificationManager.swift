//
//  NotificationManager.swift
//  SportTimer
//
//  Created by Алексей Авер on 09.07.2025.
//


import SwiftUI
import UserNotifications

struct NotificationManager {
    static func requestPermissionIfNeeded() {
        let key = "didRequestNotifications"
        let didRequest = UserDefaults.standard.bool(forKey: key)

        guard !didRequest else { return }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: key)
            }

            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
}