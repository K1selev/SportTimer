import SwiftUI
import CoreData

struct HomeView: View {
    @EnvironmentObject var store: WorkoutStore
    @AppStorage("username") private var username: String = "User"
    @Binding var selectedTabIndex: Int

    @State private var selectedDate: Date? = nil
    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 10) {
                        HStack {
                            Label("Тренировок за месяц", systemImage: "flame.fill")
                            Spacer()
                            Text("\(monthlyWorkouts.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("Длительность за месяц", systemImage: "clock")
                            Spacer()
                            Text(monthlyWorkouts.map { Int($0.duration) }.reduce(0, +).formattedTime)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Календарь тренировок")
                        .font(.headline)
                        .padding(.top, 12)
                        .padding(.trailing, 8)
                    
                    WorkoutCalendarView(workouts: store.workouts, selectedDate: $selectedDate)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                VStack(alignment: .leading, spacing: 4) {
                    if selectedDate == nil {
                        Text("Недавние тренировки")
                            .font(.headline)
                            .padding(.vertical, 4)
                            .listRowBackground(Color.clear)
                    } else if let date = selectedDate {
                        Text("\(russianDateFormatter.string(from: date))")
                            .font(.headline)
                            .padding(.vertical, 4)
                            .listRowBackground(Color.clear)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                //                List {
                //                    if filteredWorkouts.isEmpty {
                //                        Text("В этот день вы заленились")
                //                            .font(.callout)
                //                            .foregroundColor(.secondary)
                //                            .listRowBackground(Color.clear)
                //                    } else {
                //                        ForEach(filteredWorkouts) { workout in
                //                            WorkoutCardView(workout: workout)
                //                                .padding(.vertical, 4)
                //                                .swipeActions(edge: .trailing) {
                //                                    Button(role: .destructive) {
                //                                        store.deleteWorkout(workout)
                //                                    } label: {
                //                                        Label("Удалить", systemImage: "trash")
                //                                    }
                //                                }
                //                                .listRowInsets(EdgeInsets())
                //                                .listRowBackground(Color.clear)
                //                        }
                //                    }
                //                }
                //                .listStyle(.plain)
                //                .background(Color.clear)
                //            }
                
                
                List {
                    if filteredWorkouts.isEmpty {
                        if let date = selectedDate, date > Date() {
                            Text("Это ещё в будущем")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .listRowBackground(Color.clear)
                        } else {
                            Text("В этот день вы заленились")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .listRowBackground(Color.clear)
                        }
                    } else {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutCardView(workout: workout)
                                .padding(.vertical, 4)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.deleteWorkout(workout)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
            .navigationTitle("Главная")
            .mainBackground()
        }
    }

    private var filteredWorkouts: [Workout] {
        guard let selectedDate else {
            return Array(store.workouts.sorted(by: { $0.date > $1.date }).prefix(3))
        }

        return store.workouts.filter {
            calendar.isDate($0.date, inSameDayAs: selectedDate)
        }.sorted(by: { $0.date > $1.date })
    }

    private var monthlyWorkouts: [Workout] {
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }

        return store.workouts.filter {
            $0.date >= startOfMonth
        }
    }
    
    private var russianDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
}
