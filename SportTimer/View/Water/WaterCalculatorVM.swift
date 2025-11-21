//
//  WaterCalculatorVM.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import Foundation

@MainActor
final class WaterCalculatorVM: ObservableObject {
    @Published var gender: Gender?
    @Published var activity: ActivityLevel?
    @Published var age: String = ""
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var resultML: Int?

    var canCalculate: Bool {
        gender != nil && activity != nil && Int(age) != nil && Int(weight) != nil && Int(height) != nil
    }

    func calculate() {
        // Простая рекомендация (пример): 35 мл на кг + поправка по активности/полу
        guard let w = Int(weight), let g = gender, let a = activity else { return }
        var ml = w * 35
        if g == .male { ml += 250 }
        switch a {
        case .low: ml += 0
        case .medium: ml += 250
        case .high: ml += 500
        }
        resultML = ((ml + 50) / 100) * 100 // округлим до 100 мл
    }
}
