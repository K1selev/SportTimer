//
//  AvatarView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 14.07.2025.
//

import SwiftUI

struct AvatarView: View {
    @Binding var image: UIImage?

    /// Если передан, внутренний пикер НЕ открывается — тап отдаём наружу
    var onTap: (() -> Void)? = nil
    /// Включать ли встроенный PhotoPicker (true по умолчанию)
    var enablePhotoPicker: Bool = true
    /// Размер круга
    var size: CGFloat = 100

    @State private var showingPicker = false
    @State private var didSyncFromStorage = false

    var body: some View {
        Group {
            if let ui = image {
                Image(uiImage: ui).resizable().scaledToFill()
            } else if let saved = loadAvatar() {
                Image(uiImage: saved).resizable().scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .contentShape(Circle())
        .onTapGesture {
            if let onTap {
                onTap()                 // внешний обработчик (конструктор аватара)
            } else if enablePhotoPicker {
                showingPicker = true    // старое поведение — открыть галерею
            }
        }
        // 1) При первом появлении — синхронизируем биндинг из хранилища,
        // чтобы родитель тоже знал про сохранённый аватар
        .onAppear {
            guard !didSyncFromStorage, image == nil,
                  let saved = loadAvatar() else { return }
            image = saved
            didSyncFromStorage = true
        }
        // 2) Любое обновление биндинга (в т.ч. из конструктора) — сохраняем
        .onChange(of: image) { newValue in
            if let img = newValue {
                saveAvatar(img)
            } else {
                removeAvatar()
            }
        }
        .sheet(isPresented: $showingPicker) {
            if enablePhotoPicker {
                PhotoPicker { picked in
                    if let picked {
                        image = picked         // onChange выше сам сохранит
                    }
                }
            }
        }
    }

    // MARK: - Persistence

    private let storageKey = "userAvatar"

    private func saveAvatar(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.85) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadAvatar() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return UIImage(data: data)
    }

    private func removeAvatar() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
