//
//  AvatarTheme.swift
//  SportTimer
//
//  Created by Сергей Киселев on 21.11.2025.
//

import SwiftUI

/// Палитра под твои цвета (без глобальных extension'ов, чтобы не конфликтовать).
enum AvatarTheme {
    // фирменные
    static let blue   = Color(.sRGB, red: 146/255, green: 163/255, blue: 253/255, opacity: 1) // #92A3FD
    static let purple = Color(.sRGB, red: 197/255, green: 139/255, blue: 242/255, opacity: 1) // #C58BF2
    static let yellow = Color(.sRGB, red: 250/255, green: 217/255, blue: 109/255, opacity: 1) // #FAD96D

    // нейтральные
    static let hair   = Color(.sRGB, red: 43/255,  green: 43/255,  blue: 43/255,  opacity: 1)
    static let bg     = Color(.systemGray6)

    // варианты кожи
    static let skin1  = Color(.sRGB, red: 242/255, green: 214/255, blue: 201/255, opacity: 1)
    static let skin2  = Color(.sRGB, red: 233/255, green: 183/255, blue: 164/255, opacity: 1)
    static let skin3  = Color(.sRGB, red: 155/255, green:  90/255, blue:  74/255, opacity: 1)
    static let skin4  = Color(.sRGB, red: 122/255, green:  67/255, blue:  56/255, opacity: 1)
    static let skin5  = Color(.sRGB, red:  91/255, green:  47/255, blue:  39/255, opacity: 1)
    static let skin6  = Color(.sRGB, red:  60/255, green:  34/255, blue:  30/255, opacity: 1)

    // футболки
    static let shirtLavender = Color(.sRGB, red: 199/255, green: 183/255, blue: 242/255, opacity: 1)
    static let shirtBlue     = blue
    static let shirtGreen    = Color(.sRGB, red: 143/255, green: 214/255, blue: 169/255, opacity: 1)
    static let shirtYellow   = yellow
    static let shirtPink     = Color(.sRGB, red: 238/255, green: 164/255, blue: 206/255, opacity: 1)
}
