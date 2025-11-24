//
//  AvatarModels.swift
//  SportTimer
//
//  Created by Сергей Киселев on 21.11.2025.
//
import SwiftUI

// Конфигурация аватара (упрощённая: без волос и усов)
struct AvatarConfig: Equatable, Codable {
    var skin: SkinTone = .tone3
    var eyes: EyeStyle = .normal
    var glasses: Glasses = .none
    var body: BodyStyle = .rectM
    var shirt: Shirt = .lavender
}

// Палитры кожи
enum SkinTone: CaseIterable, Codable {
    case tone1, tone2, tone3, tone4, tone5, tone6
    var color: Color {
        switch self {
        case .tone1: return AvatarTheme.skin1
        case .tone2: return AvatarTheme.skin2
        case .tone3: return AvatarTheme.skin3
        case .tone4: return AvatarTheme.skin4
        case .tone5: return AvatarTheme.skin5
        case .tone6: return AvatarTheme.skin6
        }
    }
}

// Глаза
enum EyeStyle: CaseIterable, Codable { case normal, happy, sleepy }

// Очки
enum Glasses: CaseIterable, Codable { case none, round, square, sunglasses }

// Типы корпуса
// 3 прямоугольника и 5 треугольников с разными углами
enum BodyStyle: CaseIterable, Codable {
    case rectS, rectM, rectL
    case triA, triB, triC, triD, triE

    // Параметры прямоугольников
    var rectParams: (width: CGFloat, height: CGFloat, radius: CGFloat) {
        switch self {
        case .rectS: return (0.74, 0.34, 0.10)
        case .rectM: return (0.82, 0.36, 0.10)
        case .rectL: return (0.90, 0.38, 0.10)
        default:     return (0.82, 0.36, 0.10)
        }
    }

    // Параметры треугольников:
    // baseW — ширина основания, apexY — «высота» вершины (меньше — острее), skew — сдвиг вершины по X
    var triParams: (baseW: CGFloat, height: CGFloat, apexY: CGFloat, skew: CGFloat) {
        switch self {
        case .triA: return (0.90, 0.40, 0.48,  0.00) // почти равнобедренный
        case .triB: return (0.86, 0.38, 0.52, -0.05) // вершина чуть влево
        case .triC: return (0.86, 0.42, 0.46,  0.05) // вершина чуть вправо
        case .triD: return (0.94, 0.40, 0.55, -0.08) // шире и сильнее смещён
        case .triE: return (0.94, 0.40, 0.45,  0.08) // шире и острее
        default:     return (0.90, 0.40, 0.50,  0.00)
        }
    }
}

// Цвета маек
enum Shirt: CaseIterable, Codable {
    case lavender, blue, green, yellow, pink
    var color: Color {
        switch self {
        case .lavender: return AvatarTheme.shirtLavender
        case .blue:     return AvatarTheme.shirtBlue
        case .green:    return AvatarTheme.shirtGreen
        case .yellow:   return AvatarTheme.shirtYellow
        case .pink:     return AvatarTheme.shirtPink
        }
    }
}
