//
//  CustomCupSheet.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.10.2025.
//

import SwiftUI

struct CustomCupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mlText: String = ""
    let onAdd: (Int) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Введите объём стакана")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(.secondary)
                    TextField("например, 350", text: $mlText)
                        .keyboardType(.numberPad)
                    Text("мл")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.06))
                        .clipShape(Capsule())
                        .foregroundStyle(.secondary)
                }
                .frame(height: 52)
                .padding(.horizontal, 12)
                .background(WaterTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button {
                    let v = Int(mlText.filter(\.isNumber)) ?? 0
                    guard v >= 50 && v <= 2000 else { return }
                    onAdd(v)
                    dismiss()
                } label: { Text("Добавить") }
                .buttonStyle(PrimaryGradientButtonStyle())

                Spacer()
            }
            .padding(16)
            .navigationTitle("Новый стакан")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }
}
