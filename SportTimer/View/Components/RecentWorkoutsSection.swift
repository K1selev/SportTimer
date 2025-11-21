//
//  RecentWorkoutsSection.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//

import SwiftUI

struct RecentWorkoutsSection: View {
    let workouts: [Workout]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent workouts")
                .titleText()
            ScrollView {
                ForEach(workouts.prefix(3)) { workout in
                    WorkoutCardView(workout: workout)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
