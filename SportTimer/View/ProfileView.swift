//
//  ProfileView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var store: WorkoutStore
    @AppStorage("isSoundEnabled") private var isSoundEnabled = true
    @State private var showHistory = false
    @State private var showStatistics = false
    @State private var avatarImage: UIImage? = nil
    @State private var isShowingPhotoPicker = false

    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            AvatarView(image: $avatarImage)
                                .onTapGesture {
                                    isShowingPhotoPicker = true
                                }
                            EditableNameView()
                        }
                        Spacer()
                    }
                }
            }
            .mainBackground()
            .navigationTitle("Профиль")
            .sheet(isPresented: $isShowingPhotoPicker) {
                PhotoPicker { pickedImage in
                    if let image = pickedImage {
                        self.avatarImage = image
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
