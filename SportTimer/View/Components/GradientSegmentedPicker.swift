//
//  GradientSegmentedPicker.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import SwiftUI

struct GradientSegmentedPicker<Option: Hashable>: View {
    let options: [Option]
    let title: (Option) -> String
    @Binding var selection: Option
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        selection = option
                    }
                } label: {
                    Text(title(option))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Group {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppTheme.gradient)
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(.secondarySystemBackground))
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .shadow(color: isSelected ? .black.opacity(0.08) : .clear,
                        radius: 8, x: 0, y: 4)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
        )
    }
}
