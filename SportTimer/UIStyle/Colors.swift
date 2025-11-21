//
//  colors.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI
import UIKit

enum AppTheme {
    static let bg = Color(.systemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let fieldBG = Color(.secondarySystemBackground)
    static let separator = Color(.tertiaryLabel).opacity(0.2)

    static let gradient = LinearGradient(
        colors: [Color(red: 0.49, green: 0.64, blue: 1.0),
                 Color(red: 0.78, green: 0.62, blue: 1.0)],
        startPoint: .leading, endPoint: .trailing
    )
        static let gradientSwiftUI = LinearGradient(
            colors: [Color(red: 0.49, green: 0.64, blue: 1.00),
                     Color(red: 0.78, green: 0.62, blue: 1.00)],
            startPoint: .leading, endPoint: .trailing
        )
        static let gradientUI: [UIColor] = [
            UIColor(red: 0.49, green: 0.64, blue: 1.00, alpha: 1.0), // #7DA4FF
            UIColor(red: 0.78, green: 0.62, blue: 1.00, alpha: 1.0)  // #C69EFF
        ]
}
