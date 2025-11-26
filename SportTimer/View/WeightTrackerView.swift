//
//  WeightTrackerView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.


import SwiftUI
import Charts

struct WeightEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var kg: Double

    init(id: UUID = UUID(), date: Date = Date(), kg: Double) {
        self.id = id
        self.date = date
        self.kg = kg
    }
}

@MainActor
final class WeightTrackerVM: ObservableObject {
    @AppStorage("profile.weightKG") var currentWeight: Int = 50

    @Published var entries: [WeightEntry] = []
    @Published var input: String = ""

    private let key = "weight.entries"

    init() {
        load()
        if entries.isEmpty {
            // стартовая точка
            let w = Double(currentWeight)
            entries = [WeightEntry(kg: w)]
        }
        input = "\(currentWeight)"
    }

    /// Добавить/обновить запись за конкретную дату
    func addOrUpdate(on date: Date) {
        guard let val = Double(input.replacingOccurrences(of: ",", with: ".")) else { return }
        currentWeight = Int(val.rounded())

        let cal = Calendar.current
        if let idx = entries.firstIndex(where: { cal.isDate($0.date, inSameDayAs: date) }) {
            entries[idx].kg = val
        } else {
            // сохраняем с началом дня, чтобы сравнения по дню работали предсказуемо
            let dayStart = cal.startOfDay(for: date)
            entries.append(WeightEntry(date: dayStart, kg: val))
        }
        entries.sort { $0.date < $1.date }
        save()
    }

    func delete(_ e: WeightEntry) {
        entries.removeAll { $0.id == e.id }
        save()
    }

    private func save() {
        let data = try? JSONEncoder().encode(entries)
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let arr = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            entries = arr
        }
    }

    /// Последние 30 дней относительно «сегодня»
    var last30: [WeightEntry] {
        let cal = Calendar.current
        let from = cal.date(byAdding: .day, value: -29, to: cal.startOfDay(for: Date()))!
        return entries.filter { $0.date >= from }.sorted { $0.date < $1.date }
    }
}

//struct WeightTrackerView: View {
//    @StateObject private var vm = WeightTrackerVM()
//    @Environment(\.dismiss) private var dismiss
//    @FocusState private var focused: Bool
//
//    @State private var selectedDate = Date() // ← новая дата для записи/редактирования
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 16) {
//
//                // Ввод
//                VStack(spacing: 12) {
//                    // Дата + поле ввода
//                    HStack(spacing: 12) {
//                        DatePicker(
//                            "Дата",
//                            selection: $selectedDate,
//                            displayedComponents: .date
//                        )
//                        .labelsHidden()
//                        .frame(maxWidth: 170)
//
//                        TextField("Вес", text: $vm.input)
//                            .keyboardType(.decimalPad)
//                            .focused($focused)
//                            .textFieldStyle(.roundedBorder)
//
//                        Button("Сохранить") {
//                            focused = false
//                            vm.addOrUpdate(on: selectedDate)
//                        }
//                        .buttonStyle(PrimaryGradientButtonStyle())
//                    }
//
//                    // Подсказка о существующей записи на дату (опционально)
//                    if hasEntryForSelectedDate {
//                        Text("Запись за эту дату уже есть — будет обновлена.")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 8)
//
//                // График
////                if #available(iOS 16.0, *) {
////                    Chart(vm.last30) { item in
////                        LineMark(
////                            x: .value("Дата", item.date),
////                            y: .value("Вес", item.kg)
////                        )
////                        .interpolationMethod(.monotone)
////                        .foregroundStyle(Color(hex: 0x92A3FD))              // фиксируем цвет линии
////                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
////                        
////                        PointMark(
////                            x: .value("Дата", item.date),
////                            y: .value("Вес", item.kg)
////                        )
////                        .foregroundStyle(Color(hex: 0x92A3FD))              // фиксируем цвет точек
////                    }
////                    // .chartForegroundStyleScale(nil)  // ← УДАЛИТЬ, это и вызывает ошибки
////                    .frame(height: 220)
////                    .padding(.horizontal, 16)
////                } else {
//                
//                if #available(iOS 16.0, *) {
//                    let values = vm.last30.map { $0.kg }
//                    let yDomain = yScale(for: values)
//
//                    Chart(vm.last30) { item in
//                        LineMark(
//                            x: .value("Дата", item.date),
//                            y: .value("Вес", item.kg)
//                        )
//                        .interpolationMethod(.monotone)
//                        .foregroundStyle(Color(hex: 0x92A3FD))
//                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
//
//                        PointMark(
//                            x: .value("Дата", item.date),
//                            y: .value("Вес", item.kg)
//                        )
//                        .foregroundStyle(Color(hex: 0x92A3FD))
//                    }
//                    .chartYScale(domain: yDomain)
//                    .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) }
//                    .frame(height: 220)
//                    .padding(.horizontal, 16)
//                } else {
//                    // Фоллбэк: просто список
//                    List(vm.last30) { item in
//                        HStack {
//                            Text(item.date.formatted(date: .abbreviated, time: .omitted))
//                            Spacer()
//                            Text(String(format: "%.1f кг", item.kg))
//                        }
//                    }
//                    .frame(height: 220)
//                }
//
//                // История
//                List {
//                    ForEach(vm.entries.sorted(by: { $0.date > $1.date })) { e in
//                        HStack {
//                            Text(e.date.formatted(date: .abbreviated, time: .omitted))
//                            Spacer()
//                            Text(String(format: "%.1f кг", e.kg))
//                        }
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            // тап по строке — подгружаем значения в форму для редактирования
//                            selectedDate = e.date
//                            vm.input = String(format: "%.1f", e.kg)
//                            focused = true
//                        }
//                        .swipeActions(edge: .trailing) {
//                            Button(role: .destructive) {
//                                vm.delete(e)
//                            } label: {
//                                Label("Удалить", systemImage: "trash")
//                            }
//                        }
//                    }
//                }
//                .listStyle(.plain)
//            }
//            .navigationTitle("Вес")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
//                }
//            }
//            .mainBackground()
//        }
//    }
//
//    private var hasEntryForSelectedDate: Bool {
//        let cal = Calendar.current
//        return vm.entries.contains { cal.isDate($0.date, inSameDayAs: selectedDate) }
//    }
//    
//    private func yScale(for values: [Double]) -> ClosedRange<Double> {
//        let minV = values.min() ?? 0
//        let maxV = values.max() ?? 1
//        var span = maxV - minV
//        let minSpan: Double = 0.5
//        if span < minSpan { span = minSpan }
//        let pad = max(span * 0.10, 0.2)
//        return (minV - pad)...(maxV + pad)
//    }
//}




struct WeightTrackerView: View {
    @StateObject private var vm = WeightTrackerVM()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                
                VStack(spacing: 12) {
                    // Дата + поле ввода
                    HStack(spacing: 12) {
                        DatePicker(
                            "Дата",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .frame(maxWidth: 170)
                        
                        TextField("Вес", text: $vm.input)
                            .keyboardType(.decimalPad)
                            .focused($focused)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Сохранить") {
                            focused = false
                            vm.addOrUpdate(on: selectedDate)
                        }
                        .buttonStyle(PrimaryGradientButtonStyle())
                    }
                    
                    // Подсказка о существующей записи на дату (опционально)
                    if hasEntryForSelectedDate {
                        Text("Запись за эту дату уже есть — будет обновлена.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                
                // ГРАФИК (прокручиваемый по горизонтали)
                weightChart
                    .frame(height: 220)
                    .padding(.horizontal, 16)
                
                // ... ИСТОРИЯ (как у вас)
                
                
                List {
                    ForEach(vm.entries.sorted(by: { $0.date > $1.date })) { e in
                        HStack {
                            Text(e.date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text(String(format: "%.1f кг", e.kg))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // тап по строке — подгружаем значения в форму для редактирования
                            selectedDate = e.date
                            vm.input = String(format: "%.1f", e.kg)
                            focused = true
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.delete(e)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                //                            }
            }
            .navigationTitle("Вес")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
            .mainBackground()
        }
    }

    // MARK: - Прокручиваемый график

    @ViewBuilder
    private var weightChart: some View {
        if #available(iOS 16.0, *) {
            let data = vm.last30
            let values = data.map { $0.kg }
            let yDomain = yScale(for: values)

            if #available(iOS 17.0, *) {
                // iOS 17+: «родная» прокрутка оси X
                Chart(data) { item in
                    LineMark(x: .value("Дата", item.date), y: .value("Вес", item.kg))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color(hex: 0x92A3FD))
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    PointMark(x: .value("Дата", item.date), y: .value("Вес", item.kg))
                        .foregroundStyle(Color(hex: 0x92A3FD))
                }
                .chartYScale(domain: yDomain)
                .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) }
                // Делаем горизонтальную прокрутку + фиксируем «окно» (например, 14 дней)
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 14 * 24 * 60 * 60) // 14 дней
            } else {
                // iOS 16: прокрутка через ScrollView + широкая ширина Chart
                ScrollView(.horizontal, showsIndicators: true) {
                    Chart(data) { item in
                        LineMark(x: .value("Дата", item.date), y: .value("Вес", item.kg))
                            .interpolationMethod(.monotone)
                            .foregroundStyle(Color(hex: 0x92A3FD))
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        PointMark(x: .value("Дата", item.date), y: .value("Вес", item.kg))
                            .foregroundStyle(Color(hex: 0x92A3FD))
                    }
                    .chartYScale(domain: yDomain)
                    .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) }
                    // Ширина пропорциональна количеству точек (баров),
                    // чтобы не сжимать график и позволить скроллить.
                    .frame(width: chartWidth(for: data.count))
                }
            }
        } else {
            // Фоллбэк для iOS < 16 (список)
            List(vm.last30) { item in
                HStack {
                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                    Spacer()
                    Text(String(format: "%.1f кг", item.kg))
                }
            }
        }
    }

    // MARK: - Helpers

    private func yScale(for values: [Double]) -> ClosedRange<Double> {
        let minV = values.min() ?? 0
        let maxV = values.max() ?? 1
        var span = maxV - minV
        let minSpan: Double = 0.5
        if span < minSpan { span = minSpan }
        let pad = max(span * 0.10, 0.2)
        return (minV - pad)...(maxV + pad)
    }

    private func chartWidth(for count: Int) -> CGFloat {
        // Подберите шаг под ваш вкус (здесь ~28pt на точку + внутренние поля)
        let step: CGFloat = 28
        let minWidth: CGFloat = 360 // чтобы при малом числе точек занимал экран
        return max(minWidth, CGFloat(count) * step + 40)
    }

    private var hasEntryForSelectedDate: Bool {
        let cal = Calendar.current
        return vm.entries.contains { cal.isDate($0.date, inSameDayAs: selectedDate) }
    }
}
