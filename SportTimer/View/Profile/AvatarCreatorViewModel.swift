//
//  AvatarCreatorViewModel.swift
//  SportTimer
//
//  Created by Сергей Киселев on 21.11.2025.
//
//
//  AvatarCreatorViewModel.swift
//  SportTimer
//
//
//  AvatarCreatorViewModel.swift
//  SportTimer
//

import SwiftUI
import UIKit

@MainActor
final class AvatarCreatorViewModel: ObservableObject {
    @Published var cfg: AvatarConfig = .init()

    // MARK: - Actions

    /// Случайная конфигурация (волос/усов больше нет)
    func randomize(withoutHairAndMustache: Bool = true) {
        if let skin = SkinTone.allCases.randomElement() { cfg.skin = skin }
        if let eyes = EyeStyle.allCases.randomElement() { cfg.eyes = eyes }
        if let body = BodyStyle.allCases.randomElement() { cfg.body = body }
        if let shirt = Shirt.allCases.randomElement()    { cfg.shirt = shirt }
        if let glasses = Glasses.allCases.randomElement(){ cfg.glasses = glasses }
    }

    /// Сброс к значениям по умолчанию
    func reset(withoutHairAndMustache: Bool = true) {
        cfg = AvatarConfig()
    }

    // MARK: - Export

    /// Экспорт текущего аватара в UIImage (превью == экспорт)
    func exportImage(size: CGFloat = 512) -> UIImage {
        let content = AvatarRenderer(cfg: cfg)
            .frame(width: size, height: size)

        // ImageRenderer и его свойства из SwiftUI — @MainActor;
        // класс тоже @MainActor, поэтому можно обращаться напрямую.
        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale

        if let img = renderer.uiImage {
            return img
        }

        // Fallback: тоже на главном потоке
        let controller = UIHostingController(rootView: content)
        controller.view.bounds = CGRect(x: 0, y: 0, width: size, height: size)

        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let fallback = UIGraphicsImageRenderer(size: CGSize(width: size, height: size), format: format)
        return fallback.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
