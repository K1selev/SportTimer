//
//  Checkbox.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .imageScale(.large)
                    .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                configuration.label.foregroundColor(AppTheme.textSecondary)
                    .font(.footnote)
            }
        }
    }
}
