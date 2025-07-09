//
//  MainView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 09.07.2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
