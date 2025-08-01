//
//  CircleTimerView.swift
//  SportTimer
//
//  Created by Алексей Авер on 09.07.2025.
//


import SwiftUI

struct CircleTimerView: View {
    let progress: Double
    let time: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 16)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.success, lineWidth: 16)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text(time.formattedTime)
                .titleText()
        }
        .frame(width: 200, height: 200)
    }

}

#Preview {
    TimerView()
}
