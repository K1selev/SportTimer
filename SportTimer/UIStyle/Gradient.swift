//
//  Gradient.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

struct PrimaryGradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(AppTheme.gradient)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(configuration.isPressed ? 0.05 : 0.15),
                    radius: configuration.isPressed ? 4 : 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
