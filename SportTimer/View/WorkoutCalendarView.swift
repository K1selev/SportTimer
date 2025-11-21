//
//  WorkoutCalendarView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 31.07.2025.
//

import SwiftUI

struct WorkoutCalendarView: View {
    let workouts: [Workout]
    @Binding var selectedDate: Date?

    private let calendar = Calendar.current

    private var markersByDate: [Date: Set<Color>] {
        Dictionary(grouping: workouts) { calendar.startOfDay(for: $0.date) }
            .mapValues { Set($0.map(\.color)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CalendarGrid(
                selectedDate: $selectedDate,
                markersByDate: markersByDate
            )
        }
    }
}
