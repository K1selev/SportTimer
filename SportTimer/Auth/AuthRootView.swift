//
//  AuthRootView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

struct AuthRootView: View {
    @State private var showMain = false
    @Environment(\.managedObjectContext) private var moc

    var body: some View {
        NavigationView {
            RegisterView(onContinue: { showMain = true })
        }
        .fullScreenCover(isPresented: $showMain) {
            MainTabView()
                .environment(\.managedObjectContext, moc)
                .preferredColorScheme(.light)
                .onAppear { NotificationManager.requestPermissionIfNeeded() }
                .interactiveDismissDisabled()
        }
    }
}
