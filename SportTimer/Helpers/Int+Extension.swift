//
//  Int+Extension.swift
//  SportTimer
//
//  Created by Алексей Авер on 09.07.2025.
//

import Foundation

extension Int {
    var formattedTime: String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = self % 60

        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}
