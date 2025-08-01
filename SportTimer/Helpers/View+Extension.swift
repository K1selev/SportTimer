//
//  View+Extension.swift
//  SportTimer
//
//  Created by Алексей Авер on 09.07.2025.
//

import SwiftUI

extension View {
    func hideKeyboard() -> some View {
        self
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
    }
}
