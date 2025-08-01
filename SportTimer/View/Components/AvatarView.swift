//
//  AvatarView.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
//

import SwiftUI

struct AvatarView: View {
    @Binding var image: UIImage?
    @State private var showingPicker = false

    var body: some View {
        VStack {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                } else if let savedImage = loadAvatar() {
                    Image(uiImage: savedImage)
                        .resizable()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .onTapGesture { showingPicker = true }
            .sheet(isPresented: $showingPicker) {
                PhotoPicker { picked in
                    if let picked {
                        image = picked
                        saveAvatar(picked)
                    }
                }
            }
        }
    }

    private func saveAvatar(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "userAvatar")
        }
    }

    private func loadAvatar() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: "userAvatar") else { return nil }
        return UIImage(data: data)
    }
}

