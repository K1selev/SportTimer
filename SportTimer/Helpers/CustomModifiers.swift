//
//  CustomModifiers.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
//

import SwiftUI

struct TitleTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .bold, design: .default))
            .foregroundColor(.textPrimary)
    }
}


struct SubtitleTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .semibold, design: .default))
            .foregroundColor(.textSecondary)
    }
}


struct MainTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(.textPrimary)
    }
}

struct SecondaryTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.textSecondary)
    }
}

struct MainBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.background.ignoresSafeArea()
            content
                .padding(16)
        }
    }
}


extension View {
    func titleText() -> some View {
        self.modifier(TitleTextModifier())
    }
    
    func subtitleText() -> some View {
        self.modifier(SubtitleTextModifier())
    }
    
    func mainText() -> some View {
        self.modifier(MainTextModifier())
    }
    
    func secondarytext() -> some View {
        self.modifier(SecondaryTextModifier())
    }
    func mainBackground() -> some View {
        self.modifier(MainBackgroundModifier())
    }
}
