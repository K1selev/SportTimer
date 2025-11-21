//
//  IconTextField.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

struct IconTextField: View {
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .textContentType(textContentType)
        }
        .padding(.horizontal, 16).frame(height: 56)
        .background(AppTheme.fieldBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct IconSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16).frame(height: 56)
        .background(AppTheme.fieldBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
