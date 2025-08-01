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

            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Таймер")
                }
                .tag(1)

//            HistoryView(store: store)
//                .tabItem {
//                    Image(systemName: "clock.arrow.circlepath")
//                    Text("History")
//                }
//                .tag(2)
            
            ManualEntryView()
                .tabItem {
                    Image(systemName: "plus")
                    Text("Добавить")
                }
                .tag(2)

            ActivityView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Активность")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
}
