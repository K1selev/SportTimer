//
//  CalorieCounterViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 25.11.2025.
//
import SwiftUI
import PhotosUI
import Vision

struct NutritionFacts: Identifiable, Hashable {
    let id = UUID()
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var servingSize: Double
    var servingUnit: String
}

struct FoodEntry: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var quantity: Double
    var facts: NutritionFacts
    var photo: UIImage? = nil
    var date: Date = Date()

    var totalCalories: Double { facts.calories * quantity }
    var isToday: Bool { Calendar.current.isDateInToday(date) }
}

protocol NutritionAIProtocol {
    func analyze(image: UIImage) async throws -> FoodEntry?
}

final class VisionNutritionAI: NutritionAIProtocol {
    func analyze(image: UIImage) async throws -> FoodEntry? {
        let texts = try await recognizeText(in: image)
        let parsed = OCRLabelParser.parse(lines: texts)
        guard let facts = parsed.facts else { return nil }
        return FoodEntry(name: parsed.name ?? "Продукт",
                         quantity: 1,
                         facts: facts,
                         photo: image,
                         date: Date())                  // ← выставляем дату
    }

    private func recognizeText(in image: UIImage) async throws -> [String] {
        guard let cg = image.cgImage else { return [] }
        let req = VNRecognizeTextRequest()
        req.recognitionLevel = .accurate
        req.usesLanguageCorrection = true
        req.recognitionLanguages = ["ru-RU","en-US"]
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        try handler.perform([req])
        return (req.results ?? []).compactMap { $0.topCandidates(1).first?.string }
    }
}

enum OCRLabelParser {
    static func parse(lines: [String]) -> (name: String?, facts: NutritionFacts?) {
        let joined = lines.joined(separator: " ").lowercased()
        var servingSize = 100.0
        var servingUnit = "г"
        if joined.contains("на 100") { servingSize = 100; servingUnit = "г" }
        if let s = findNumber(around: "порц", in: joined) { servingSize = s; servingUnit = "порция" }

        let cal = findNumber(around: "ккал", in: joined)
               ?? findNumber(around: "кал", in: joined)
               ?? findNumber(around: "energy", in: joined)

        let prot = findNumber(around: "бел", in: joined) ?? findNumber(around: "protein", in: joined)
        let fat  = findNumber(around: "жир", in: joined) ?? findNumber(around: "fat", in: joined)
        let carb = findNumber(around: "углев", in: joined) ?? findNumber(around: "carb", in: joined)

        var calories = cal
        if calories == nil, let p = prot, let f = fat, let c = carb { calories = p*4 + f*9 + c*4 }
        guard let kcal = calories else { return (nil, nil) }

        let facts = NutritionFacts(
            calories: kcal, protein: prot ?? 0, fat: fat ?? 0, carbs: carb ?? 0,
            servingSize: servingSize, servingUnit: servingUnit
        )
        let name = lines.first { !$0.trimmingCharacters(in: .whitespaces).isEmpty && !$0.contains(where: { $0.isNumber }) }
        return (name, facts)
    }

    private static func findNumber(around key: String, in text: String) -> Double? {
        guard let r = text.range(of: key) else { return nil }
        let tail = text[r.upperBound...]
        let pattern = #"([-+]?\d{1,4}([.,]\d{1,2})?)"#
        if let match = tail.range(of: pattern, options: .regularExpression) {
            return Double(String(tail[match]).replacingOccurrences(of: ",", with: "."))
        }
        return nil
    }
}

@MainActor
final class CalorieCounterViewModel: ObservableObject {
    @Published var entries: [FoodEntry] = []
    @Published var showManual = false
    @Published var showPhoto  = false
    @Published var analyzing  = false
    @Published var pickedImage: UIImage? = nil
    @Published var errorText: String? = nil

    @AppStorage("nutrition.goalKcal")  var kcalGoal: Int = 2000
    @AppStorage("nutrition.todayKcal") var kcalToday: Int = 0

    private let ai: NutritionAIProtocol

    init(ai: NutritionAIProtocol = VisionNutritionAI()) {
        self.ai = ai
        loadDraft()
        recalcAndSyncToday()
    }

    var totalCalories: Double {
        entries.filter { $0.isToday }.reduce(0) { $0 + $1.totalCalories }
    }

    // MARK: - Actions

    func addManual(_ entry: FoodEntry) {
        var e = entry
        e.date = Date()
        entries.insert(e, at: 0)
        saveDraft()
        recalcAndSyncToday()
    }

    func delete(_ entry: FoodEntry) {
        entries.removeAll { $0.id == entry.id }
        saveDraft()
        recalcAndSyncToday()
    }

    func update(_ entry: FoodEntry) {
        if let idx = entries.firstIndex(where: {$0.id == entry.id}) {
            entries[idx] = entry
            saveDraft()
            recalcAndSyncToday()
        }
    }

    func analyzePicked() async {
        guard let img = pickedImage else { return }
        analyzing = true
        defer { analyzing = false }
        do {
            if let result = try await ai.analyze(image: img) {
                entries.insert(result, at: 0)
                saveDraft()
                recalcAndSyncToday()
            } else {
                errorText = "Не удалось распознать продукт. Заполните вручную."
            }
        } catch {
            errorText = error.localizedDescription
        }
    }
    
    private struct Persist: Codable {
        let items: [Item]
        struct Item: Codable {
            let name: String
            let quantity: Double
            let calories: Double
            let protein: Double
            let fat: Double
            let carbs: Double
            let servingSize: Double
            let servingUnit: String
            let dateISO: String
        }
    }

    private func saveDraft() {
        let iso = ISO8601DateFormatter()
        let items = entries.map {
            Persist.Item(
                name: $0.name,
                quantity: $0.quantity,
                calories: $0.facts.calories,
                protein:  $0.facts.protein,
                fat:      $0.facts.fat,
                carbs:    $0.facts.carbs,
                servingSize: $0.facts.servingSize,
                servingUnit: $0.facts.servingUnit,
                dateISO: iso.string(from: $0.date)
            )
        }
        if let data = try? JSONEncoder().encode(Persist(items: items)) {
            UserDefaults.standard.set(data, forKey: "calorie.entries")
        }
    }

    private func loadDraft() {
        guard let data = UserDefaults.standard.data(forKey: "calorie.entries"),
              let persist = try? JSONDecoder().decode(Persist.self, from: data) else { return }
        let iso = ISO8601DateFormatter()
        self.entries = persist.items.map {
            FoodEntry(
                name: $0.name,
                quantity: $0.quantity,
                facts: NutritionFacts(
                    calories: $0.calories,
                    protein:  $0.protein,
                    fat:      $0.fat,
                    carbs:    $0.carbs,
                    servingSize: $0.servingSize,
                    servingUnit: $0.servingUnit
                ),
                photo: nil,
                date: iso.date(from: $0.dateISO) ?? Date()
            )
        }
    }
    private func recalcAndSyncToday() {
        let total = entries
            .filter { $0.isToday }
            .reduce(0.0) { $0 + $1.totalCalories }
        kcalToday = Int(round(total))
    }
}
