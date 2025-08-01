//
//  CalendarGrid.swift
//  SportTimer
//
//  Created by Сергей Киселев on 31.07.2025.
//

import SwiftUI

struct CalendarGrid: View {
    @Binding var selectedDate: Date?
    let markersByDate: [Date: Set<Color>]

    private let calendar = Calendar.current
    private let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    @State private var currentMonth: Date = Date()

    var body: some View {
        VStack {
            HStack {
                Button(action: { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)! }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                Spacer()
                Button(action: { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)! }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: .init(), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Text(day).font(.caption).foregroundColor(.gray)
                }

                ForEach(generateDays()) { date in
                    let markers = markersByDate[date.date] ?? []
                    let isSelected = calendar.isDate(date.date, inSameDayAs: selectedDate ?? Date.distantPast)

                    Button {
                        selectedDate = isSelected ? nil : date.date
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                                .frame(width: 36, height: 36)

                            VStack(spacing: 2) {
                                Text("\(calendar.component(.day, from: date.date))")
                                    .foregroundColor(.primary)
                                HStack(spacing: 2) {
                                    ForEach(Array(markers.prefix(3)), id: \.self) { color in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                            }
                        }
                    }
                    .disabled(!date.isWithinCurrentMonth)
                }
            }
            .padding(.horizontal)
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    private func generateDays() -> [CalendarDay] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (firstWeekday + 5) % 7

        let totalDays = range.count + leadingEmptyDays
        var days: [CalendarDay] = []

        for i in 0..<totalDays {
            if i < leadingEmptyDays {
                days.append(CalendarDay(date: calendar.date(byAdding: .day, value: i - leadingEmptyDays, to: startOfMonth)!, isWithinCurrentMonth: false))
            } else {
                let date = calendar.date(byAdding: .day, value: i - leadingEmptyDays, to: startOfMonth)!
                days.append(CalendarDay(date: date, isWithinCurrentMonth: true))
            }
        }

        return days
    }

    struct CalendarDay: Identifiable {
        let id = UUID()
        let date: Date
        let isWithinCurrentMonth: Bool
    }
}
