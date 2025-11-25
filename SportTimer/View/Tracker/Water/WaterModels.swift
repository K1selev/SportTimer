//
//  WaterModels.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import Foundation
import SwiftUI

enum Gender: String, CaseIterable, Identifiable { case male = "Male", female = "Female"
    var id: String { rawValue }
}

enum ActivityLevel: String, CaseIterable, Identifiable {
    case low = "Low", medium = "Medium", high = "High"
    var id: String { rawValue }
}

struct WaterEntry: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let amountML: Int
}

struct WaterGoal: Equatable {
    var dailyML: Int
}

enum CupSize: Int, CaseIterable, Identifiable {
    case ml200 = 200, ml250 = 250, ml300 = 300, ml500 = 500
    var id: Int { rawValue }
    var title: String { "\(rawValue) ml" }
}

enum CupML: Int, CaseIterable, Identifiable {
    case ml200 = 200, ml250 = 250, ml300 = 300, ml500 = 500
    var id: Int { rawValue }
    var title: String { "\(rawValue) мл" }
}
