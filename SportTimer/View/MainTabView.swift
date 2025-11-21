//
//  MainTabView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var selectedTabIndex: Int = 0
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            HomeView(selectedTabIndex: $selectedTabIndex)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)
            
            ManualEntryView()
                .tabItem {
                    Image(systemName: "plus")
                    Text("Тренировка")
                }
                .tag(1)

            WaterIntakeView()
                .tabItem {
                    Image(systemName: "drop.fill")
                    Text("Вода")
                }
                .tag(2)

            ActivityView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Активность")
                }
                .tag(3)
        }
        .tint(Color(red: 146/255, green: 163/255, blue: 253/255))
    }
}

#Preview {
    MainTabView()
}
