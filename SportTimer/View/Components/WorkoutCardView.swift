//
//  WorkoutCardView.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
//

import SwiftUI

struct WorkoutCardView: View {
    let workout: Workout

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.type)
                    .mainText()

                Text(durationFormatted(from: workout.duration))
                    .secondarytext()

                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                    .secondarytext()
                
                Text(workout.notes ?? "")
                    .secondarytext()
            }
            .padding()
            Spacer()
        
        }
        .background(.white)
        .cornerRadius(12)
    }

    private func durationFormatted(from seconds: Int32) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
