//
//  TimerViewModel.swift
//  SportTimer
//
//  Created by Алексей Авер on 09.07.2025.
//

import Foundation
import UserNotifications

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var elasped: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var workoutType: WorkoutType = .other
    @Published var notes: String = ""
    @Published var isSaving: Bool = false
        
    private var startTime: Date?
    private var timerTask: Task<Void, Never>?
    
    
    func start() {
        guard !isRunning else { return }
        SoundPlayer.shared.playSound(named: "click")
        isRunning = true
        startTime = Date().addingTimeInterval(-elasped)
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000)
                elasped = Date().timeIntervalSince(startTime ?? Date())
            }
        }
    }
    
    func pause() {
        guard isRunning else { return }
        SoundPlayer.shared.playSound(named: "click")
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    func stop(store: WorkoutStore) {
        guard elasped > 0 else { return }
        SoundPlayer.shared.playSound(named: "stop")
        pause()
        isSaving = true
        
        Task {
            await store.addWorkout(
                type: workoutType.rawValue,
                duration: Int(elasped),
                date: Date(),
                notes: notes
            )
            
            await MainActor.run {
                self.elasped = 0
                self.notes = ""
                self.workoutType = .other
                self.isSaving = false
            }
        }
        scheduleNotification()
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Sport Timer"
        content.body = "Workout is finished! \(workoutType.rawValue) on \(Int(elasped).formattedTime)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
    }
}
