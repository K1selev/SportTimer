//
//  ProfileView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//
//
//  ProfileView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//

import SwiftUI

private extension View {
    func gradientForeground() -> some View {
        overlay(
            LinearGradient(
                colors: [
                    Color(red: 146/255, green: 163/255, blue: 253/255), // #92A3FD
                    Color(red: 157/255, green: 206/255, blue: 1.00)     // #9DCEFF
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .mask(self)
    }
}

private struct StatItemView: View {
    let valueText: String
    let caption: String

    var body: some View {
        VStack(spacing: 4) {
            Text(valueText)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .gradientForeground()
            Text(caption)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileView: View {
    @EnvironmentObject var store: WorkoutStore

    @AppStorage("profile.heightCM") private var heightCM: Int = 180
    @AppStorage("profile.weightKG") private var weightKG: Int = 65
    @AppStorage("profile.ageY")     private var ageYears: Int = 22

    @State private var avatarImage: UIImage? = nil
    @State private var showCreator = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                // Header: левая половина — аватар, правая — текст.
                GeometryReader { proxy in
                    let half = proxy.size.width / 2

                    HStack(spacing: 0) {
                        // Левая половина — аватар с увеличенным левым отступом.
                        HStack {
                            AvatarView(
                                image: $avatarImage,
                                onTap: { showCreator = true },    // ← открываем конструктор
                                enablePhotoPicker: false,         // ← отключаем внутренний пикер
                                size: 72
                            )
                            .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            Spacer(minLength: 0)
                        }
                        .frame(width: half, alignment: .leading)
                        .padding(.leading, 36)

                        // Правая половина — имя и подпись, левый край по центру экрана.
                        VStack(alignment: .leading, spacing: 4) {
                            EditableNameView()
                                .font(.system(size: 20, weight: .semibold))
                                .lineLimit(1)

                            Text("Lose a Fat Program")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .frame(width: half, alignment: .leading)
                    }
                    .frame(height: 88)
                }
                .frame(height: 88)
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Метрики
                HStack(spacing: 0) {
                    StatItemView(valueText: "\(heightCM)cm", caption: "Height")
                    StatItemView(valueText: "\(weightKG)kg", caption: "Weight")
                    StatItemView(valueText: "\(ageYears)yo", caption: "Age")
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreator) {
                AvatarCreatorView { img in
                    self.avatarImage = img
                }
            }
        }
    }
}
