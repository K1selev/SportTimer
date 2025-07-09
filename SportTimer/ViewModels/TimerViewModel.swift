//
//  TimerViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import CoreData

class TimerViewModel: ObservableObject {
    @Published var duration: Int = 0
    @Published var isRunning = false
    @Published var selectedType = "Strength"
    @Published var notes: String = ""

    private var timer: AnyCancellable?
    private var startDate: Date?
    
    let workoutTypes = ["Strength", "Cardio", "Yoga", "Stretching", "Other"]

    func startTimer() {
        if !isRunning {
            isRunning = true
            startDate = Date()
            scheduleNotification()
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.duration += 1
                }
        }
    }

    func pauseTimer() {
        isRunning = false
        timer?.cancel()
        cancelNotification()
    }

    func stopTimer(context: NSManagedObjectContext) {
        isRunning = false
        timer?.cancel()
        cancelNotification()
        saveWorkout(context: context)
        duration = 0
        notes = ""
    }

//    private func saveWorkout(context: NSManagedObjectContext) {
//        Workout.create(type: selectedType, duration: duration, date: Date(), notes: notes, context: context)
//    }
    
    private func saveWorkout(context: NSManagedObjectContext) {
        let newWorkout = Workout(context: context)
        newWorkout.type = selectedType
        newWorkout.duration = Int16(duration)
        newWorkout.date = Date()
        newWorkout.notes = notes

        do {
            try context.save()
            print("Workout saved successfully.")
        } catch {
            print("Failed to save workout: \(error.localizedDescription)")
        }
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "SportTimer"
        content.body = "Тренировка завершена!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "WorkoutEnd", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["WorkoutEnd"])
    }
}
