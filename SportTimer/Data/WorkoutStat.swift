//
//  WorkoutStat.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.08.2025.
//

import Foundation

struct WorkoutStat: Identifiable {
    let id = UUID()
    let type: String
    let totalDuration: Int
}
