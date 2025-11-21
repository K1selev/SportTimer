//
//  SocialButtons.swift
//  SportTimer
//
//  Created by Сергей Киселев on 01.10.2025.
//

import SwiftUI

struct SocialButtons: View {
    var onGoogle: () -> Void
    var onFacebook: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            Button(action: onGoogle) {
                Image(systemName: "g.circle.fill")
                    .font(.system(size: 36, weight: .regular))
            }
            Button(action: onFacebook) {
                Image(systemName: "f.circle.fill")
                    .font(.system(size: 36, weight: .regular))
            }
        }.foregroundColor(.primary)
    }
}
