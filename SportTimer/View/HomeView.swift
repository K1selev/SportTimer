import SwiftUI
import CoreData

// MARK: - helpers used in header
private extension View {
    func gradientForeground() -> some View {
        overlay(
            LinearGradient(
                colors: [
                    Color(red: 146/255, green: 163/255, blue: 253/255), // #92A3FD
                    Color(red: 157/255, green: 206/255, blue: 1.00)     // #9DCEFF
                ],
                startPoint: .leading, endPoint: .trailing
            )
        ).mask(self)
    }
}

private struct StatItemView: View {
    let valueText: String
    let caption: String
    var action: (() -> Void)? = nil

    var body: some View {
        let content = VStack(spacing: 4) {
            Text(valueText)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .gradientForeground()
            Text(caption)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)

        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}

// MARK: - Home
struct HomeView: View {
    @EnvironmentObject var store: WorkoutStore
    @AppStorage("username") private var username: String = "User"
    @Binding var selectedTabIndex: Int

    @AppStorage("profile.weightKG") private var weightKG: Int = 65
    @State private var avatarImage: UIImage? = nil
    @State private var showCreator = false

    @State private var showWeightTracker = false

    @State private var selectedDate: Date? = nil
    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Профильная карточка: аватар + метрики справа
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        AvatarView(
                            image: $avatarImage,
                            onTap: { showCreator = true },
                            enablePhotoPicker: false,
                            size: 56
                        )
                        .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                        // Метрики ТАПАБЕЛЬНЫЕ
                        HStack(spacing: 0) {
                            // Вес → экран трекинга веса
                            StatItemView(
                                valueText: "\(weightKG) Кг",
                                caption: "Вес",
                                action: { showWeightTracker = true }
                            )

                            // Workouts → вкладка «Тренировка» (index 1)
                            StatItemView(
                                valueText: "\(monthlyWorkouts.count)",
                                caption: "Workouts",
                                action: { selectedTabIndex = 1 }
                            )

                            // Duration → вкладка «Тренировка» (index 1)
                            StatItemView(
                                valueText: totalMonthlyDisplay,
                                caption: "Duration",
                                action: { selectedTabIndex = 1 }
                            )
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 16)
                .padding(.top, -16)

                // MARK: Календарь
                VStack(alignment: .leading, spacing: 16) {
                    Text("Календарь тренировок")
                        .font(.headline)

                    WorkoutCalendarView(
                        workouts: store.workouts,
                        selectedDate: $selectedDate
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // MARK: Заголовок списка
                VStack(alignment: .leading, spacing: 4) {
                    if selectedDate == nil {
                        Text("Недавние тренировки")
                            .font(.headline)
                            .padding(.vertical, 4)
                    } else if let date = selectedDate {
                        Text(russianDateFormatter.string(from: date))
                            .font(.headline)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Список
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
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .sheet(isPresented: $showCreator) {
                AvatarCreatorView { img in
                    self.avatarImage = img
                }
            }
            .sheet(isPresented: $showWeightTracker) {
                WeightTrackerView() // новый экран
            }
            .mainBackground()
        }
    }

    // MARK: - Computed

    private var filteredWorkouts: [Workout] {
        guard let selectedDate else {
            return Array(store.workouts.sorted(by: { $0.date > $1.date }).prefix(3))
        }
        return store.workouts
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted(by: { $0.date > $1.date })
    }

    private var monthlyWorkouts: [Workout] {
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return [] }
        return store.workouts.filter { $0.date >= startOfMonth }
    }

    private var totalMonthlyDuration: Int {
        monthlyWorkouts.map { Int($0.duration) }.reduce(0, +)
    }

    /// Формат: < 60 мин → "MM", ≥ 60 мин → "H:MM"
    private var totalMonthlyDisplay: String {
        let hours = totalMonthlyDuration / 3600
        let minutes = (totalMonthlyDuration % 3600) / 60
        if hours == 0 {
            return "\(minutes)"
        } else {
            return "\(hours):" + String(format: "%02d", minutes)
        }
    }

    private var russianDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }
}
