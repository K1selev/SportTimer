//
//  WaterTheme.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import SwiftUI

enum WaterTheme {
    static let bg = Color(.systemBackground)
    static let card = Color(.secondarySystemBackground)
    static let textSecondary = Color(.secondaryLabel)
    
    // Градиент как в твоих экранах
    static let gradient = LinearGradient(
        colors: [Color(red: 146/255, green: 163/255, blue: 253/255),  // #92A3FD
                 Color(red: 157/255, green: 206/255, blue: 1.0)],      // #9DCEFF
        startPoint: .leading, endPoint: .trailing
    )
    
    // Фиолетовый из палитры
    static let purple = Color(red: 197/255, green: 139/255, blue: 242/255) // #C58BF2
    // Мягкий жёлтый под стиль
    static let yellow = Color(red: 255/255, green: 224/255, blue: 125/255) // #FFE07D
    
    
    // Основной голубой градиент
    static let blueGradient = LinearGradient(
        colors: [
            Color(red: 146/255, green: 163/255, blue: 253/255), // #92A3FD
            Color(red: 157/255, green: 206/255, blue: 1.00)     // #9DCEFF
        ],
        startPoint: .leading, endPoint: .trailing
    )
    
    // Сиреневый градиент (для значений ниже цели)
    static let purpleGradient = LinearGradient(
        colors: [
            Color(red: 238/255, green: 164/255, blue: 206/255), // #EEA4CE
            Color(red: 197/255, green: 139/255, blue: 242/255)  // #C58BF2
        ],
        startPoint: .leading, endPoint: .trailing
    )
    
}
