import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var store: WorkoutStore
    @StateObject private var viewModel = ActivityViewModel()
    @State private var currentMonthOffset = 0
    @State private var showGoalInput = false
    
    @AppStorage("isSoundEnabled") private var isSoundEnabled = true
    // Навигация по другим экранам
    @State private var showHistory = false
    @State private var showAchievements = false
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showResetAlert = false

    private var calendar = Calendar.current

    private var currentMonthDate: Date {
        calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonthDate).capitalized
    }

    private var isFutureMonth: Bool {
        calendar.compare(currentMonthDate, to: Date(), toGranularity: .month) == .orderedDescending
    }

    private var workoutsThisMonth: [Workout] {
        store.workouts.filter {
            calendar.isDate($0.date ?? Date(), equalTo: currentMonthDate, toGranularity: .month)
        }
    }

    private var stats: [WorkoutStat] {
        WorkoutType.allCases.map { type in
            let filtered = workoutsThisMonth.filter { $0.type == type.rawValue }
            let durations = filtered.map { Int($0.duration) }
            return WorkoutStat(type: type.rawValue, totalDuration: durations.reduce(0, +))
        }
    }

    var body: some View {
        NavigationStack {
            
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Button {
                            if currentMonthOffset > -120 {
                                currentMonthOffset -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(currentMonthOffset <= -120 ? .gray : .blue)
                                .frame(width: 44, height: 44) // делаем область клика побольше
                        }
                        .disabled(currentMonthOffset <= -120)
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        
                        Spacer()
                        
                        Text(monthName)
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            if currentMonthOffset < 0 {
                                currentMonthOffset += 1
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(isFutureMonth ? .gray : .blue)
                                .frame(width: 44, height: 44)
                        }
                        .disabled(isFutureMonth)
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                    .padding(.vertical, 8)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)) // здесь задаём отступы у секции
                    
                    if isFutureMonth {
                        Text("Всё впереди!")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
                    } else if workoutsThisMonth.isEmpty {
                        Text("В этом месяце вы не тренировались.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
                    } else {
                        HStack {
                            Spacer()
                            ActivityRingsView(stats: stats, viewModel: viewModel)
                                .frame(width: 220, height: 220)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 10, trailing: 16))
                    }
                }
            }
            
            
            List {
                // MARK: - Header с навигацией по месяцам и кольцами активности
                
                
                // MARK: - Активность: статистика по типам тренировок
                if !isFutureMonth && !workoutsThisMonth.isEmpty {
                    Section(header: Text("Активность")) {
                        ForEach(stats.filter { $0.totalDuration > 0 }) { stat in
                            HStack {
                                Circle()
                                    .fill(WorkoutType(rawValue: stat.type)?.color ?? .gray)
                                    .frame(width: 10, height: 10)
                                Text(stat.type)
                                    .mainText()
                                Spacer()
                                Text("\(Int(Double(stat.totalDuration) / 60)) мин / \(Int(viewModel.goal(for: stat.type)) * 60) мин")
                                    .secondarytext()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // MARK: - Отдельные кнопки из профиля
                Section(header: Text("История")) {
                    Button {
                        showHistory = true
                    } label: {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.gray)
                            Text("История тренировок")
                                .mainText()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        showAchievements = true
                    } label: {
                        HStack {
                            Image(systemName: "rosette")
                                .foregroundStyle(.gray)
                            Text("Изменить цели")
                                .mainText()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        showSettings = true
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.gray)
                            Text("Профиль")
                                .mainText()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Toggle(isOn: $isSoundEnabled) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(.gray)
                            Text("Звук таймера")
                                .mainText()
                        }
                        
                    }
                    
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundStyle(.danger)
                            Text("Удалить данные")
                                .mainText()
                        }
                    }
                }
                Section(header: Text("О нас")) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.gray)
                        Text("О приложении")
                            .mainText()
                        Spacer()
                        Text("Ver 1.0.0")
                            .secondarytext()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Активность")
            
            .sheet(isPresented: $showGoalInput) {
                GoalInputView(tempGoals: viewModel.goals) { newGoals in
                    viewModel.saveGoals(newGoals)
                }
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(store: store)
            }
            .sheet(isPresented: $showAchievements) {
                GoalInputView(tempGoals: viewModel.goals) { newGoals in
                    viewModel.saveGoals(newGoals)
                }
            }
            .sheet(isPresented: $showSettings) {
                ProfileView() // Замени на реальный экран настроек
            }
            .sheet(isPresented: $showAbout) {
//                AboutView() // Замени на реальный экран "О приложении"
            }
        
            .alert("Удалить все данные?", isPresented: $showResetAlert) {
                Button("Удалить", role: .destructive) {
                    store.deleteAllWorkouts()
                }
                Button("Отмена", role: .cancel) {}
            }
            .mainBackground()
        }
    }
}

extension Text {
    func mainText() -> some View {
        self.font(.body)
    }

    func secondarytext() -> some View {
        self.font(.subheadline).foregroundColor(.secondary)
    }
}
