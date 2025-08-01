//
//  AppButton.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import SwiftUI

struct AppButton: View {
    let title: String
    let color: Color
    var isDisabled: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity)
                .background(isDisabled ? Color.gray : color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(isPressed && !isDisabled ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isDisabled { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
        .disabled(isDisabled)
    }
}
