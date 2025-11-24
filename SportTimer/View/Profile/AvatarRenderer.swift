//
//  AvatarRenderer.swift
//  SportTimer
//
//  Created by Сергей Киселев on 21.11.2025.
//

import SwiftUI

/// Рендер полностью в относительных координатах → превью = экспорт.
struct AvatarRenderer: View {
    var cfg: AvatarConfig
    
    var body: some View {
        GeometryReader { geo in
            let S = min(geo.size.width, geo.size.height)
            
            ZStack {
                AvatarTheme.bg
                
                bodyLayer(S)          // корпус
                neckLayer(S)          // шея (цвет кожи)
                headLayer(S)          // голова, глаза, рот
                glassesLayer(S)       // очки (если есть)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipShape(RoundedRectangle(cornerRadius: S * 0.06, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: S * 0.06, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Body
    
    private func bodyLayer(_ S: CGFloat) -> some View {
        ZStack {
            switch cfg.body {
            case .rectS, .rectM, .rectL:
                let p = cfg.body.rectParams
                let w = S * p.width
                let h = S * p.height
                RoundedRectangle(cornerRadius: S * p.radius, style: .continuous)
                    .fill(cfg.shirt.color)
                    .frame(width: w, height: h)
                    .position(x: S * 0.5, y: S * (1.0 - h * 0.5 / S))
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                
            case .triA, .triB, .triC, .triD, .triE:
                let p = cfg.body.triParams
                let baseW = S * p.baseW
                let h = S * p.height
                let centerX = S * (0.5 + p.skew)
                let centerY = S * (1.0 - h * 0.45 / S)
                Path { path in
                    let top = CGPoint(x: centerX, y: centerY - h * p.apexY)
                    let left = CGPoint(x: centerX - baseW/2, y: centerY + h/2)
                    let right = CGPoint(x: centerX + baseW/2, y: centerY + h/2)
                    path.move(to: top)
                    path.addLine(to: left)
                    path.addLine(to: right)
                    path.closeSubpath()
                }
                .fill(cfg.shirt.color)
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    // MARK: - Neck (skin color)
    
    private func neckLayer(_ S: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: S * 0.02, style: .continuous)
            .fill(cfg.skin.color)
            .frame(width: S * 0.22, height: S * 0.06)
            .position(x: S * 0.5, y: S * 0.67)
    }
    
    // MARK: - Head + face
    
    private func headLayer(_ S: CGFloat) -> some View {
        let headW = S * 0.62
        let headH = S * 0.50
        let headY = S * 0.55
        
        let earR = S * 0.06
        let earY = headY - headH * 0.06
        
        return ZStack {
            Circle().fill(cfg.skin.color)
                .frame(width: earR * 2, height: earR * 2)
                .position(x: S * 0.5 - headW * 0.52, y: earY)
            Circle().fill(cfg.skin.color)
                .frame(width: earR * 2, height: earR * 2)
                .position(x: S * 0.5 + headW * 0.52, y: earY)
            
            RoundedRectangle(cornerRadius: S * 0.09, style: .continuous)
                .fill(cfg.skin.color)
                .frame(width: headW, height: headH)
                .overlay(
                    RoundedRectangle(cornerRadius: S * 0.09, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .position(x: S * 0.5, y: headY)
            
            eyesLayer(S, headW: headW, headH: headH, headY: headY)
            mouthLayer(S, headY: headY, headH: headH)
        }
    }
    
    private func eyesLayer(_ S: CGFloat, headW: CGFloat, headH: CGFloat, headY: CGFloat) -> some View {
        let eyeW = S * 0.14, eyeH = S * 0.10
        let y = headY - headH * 0.08
        return HStack(spacing: S * 0.09) {
            eye(S, eyeW: eyeW, eyeH: eyeH)
            eye(S, eyeW: eyeW, eyeH: eyeH)
        }
        .position(x: S * 0.5, y: y)
    }
    
    @ViewBuilder private func eye(_ S: CGFloat, eyeW: CGFloat, eyeH: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: S * 0.03, style: .continuous)
                .fill(Color.white)
                .frame(width: eyeW, height: eyeH)
            switch cfg.eyes {
            case .normal:
                Circle().fill(Color.black)
                    .frame(width: eyeW * 0.38, height: eyeW * 0.38)
                    .offset(x: eyeW * 0.08)
            case .happy:
                Circle().stroke(lineWidth: S * 0.008)
                    .frame(width: eyeW * 0.52, height: eyeH * 0.55)
                    .offset(y: eyeH * 0.15)
            case .sleepy:
                Capsule().fill(Color.black)
                    .frame(width: eyeW * 0.50, height: S * 0.01)
            }
        }
    }
    
    private func mouthLayer(_ S: CGFloat, headY: CGFloat, headH: CGFloat) -> some View {
        Path { p in
            p.addArc(center: .zero, radius: S * 0.035,
                     startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
        }
        .stroke(Color.black.opacity(0.8), lineWidth: S * 0.012)
        .frame(width: S * 0.12, height: S * 0.05)
        .position(x: S * 0.5, y: headY + headH * 0.18)
    }
    
    // MARK: - Glasses
    
    // MARK: - Glasses (линзы + переносица + дужки к ушам)
    private func glassesLayer(_ S: CGFloat) -> some View {
        let earXLeft  = S * (0.5 - 0.31)
        let earXRight = S * (0.5 + 0.31)
        let yAll      = S * 0.515      // опущены для всех стилей

        @ViewBuilder
        func temples(from leftEdge: CGFloat, to rightEdge: CGFloat, y: CGFloat) -> some View {
            Path { p in
                p.move(to: CGPoint(x: leftEdge, y: y))
                p.addQuadCurve(to: CGPoint(x: earXLeft, y: y),
                               control: CGPoint(x: (leftEdge + earXLeft)/2, y: y - S*0.015))
            }
            .stroke(Color.black.opacity(0.8), lineWidth: S * 0.010)
            Path { p in
                p.move(to: CGPoint(x: rightEdge, y: y))
                p.addQuadCurve(to: CGPoint(x: earXRight, y: y),
                               control: CGPoint(x: (rightEdge + earXRight)/2, y: y - S*0.015))
            }
            .stroke(Color.black.opacity(0.8), lineWidth: S * 0.010)
        }

        return Group {
            switch cfg.glasses {
            case .none:
                EmptyView()

            case .round:
                let r = S * 0.072, gap = S * 0.06
                let cxL = S*0.5 - (r + gap/2)
                let cxR = S*0.5 + (r + gap/2)
                temples(from: cxL - r, to: cxR + r, y: yAll)
                Circle().stroke(Color.black.opacity(0.85), lineWidth: S * 0.012)
                    .frame(width: r*2, height: r*2).position(x: cxL, y: yAll)
                Circle().stroke(Color.black.opacity(0.85), lineWidth: S * 0.012)
                    .frame(width: r*2, height: r*2).position(x: cxR, y: yAll)
                Capsule().fill(Color.black.opacity(0.85))
                    .frame(width: gap * 0.55, height: S * 0.012)
                    .position(x: S*0.5, y: yAll)

            case .square:
                let w = S * 0.16, h = S * 0.12, r = S * 0.02, gap = S * 0.06
                let cxL = S*0.5 - (w/2 + gap/2)
                let cxR = S*0.5 + (w/2 + gap/2)
                temples(from: cxL - w/2, to: cxR + w/2, y: yAll)
                RoundedRectangle(cornerRadius: r)
                    .stroke(Color.black.opacity(0.85), lineWidth: S * 0.012)
                    .frame(width: w, height: h).position(x: cxL, y: yAll)
                RoundedRectangle(cornerRadius: r)
                    .stroke(Color.black.opacity(0.85), lineWidth: S * 0.012)
                    .frame(width: w, height: h).position(x: cxR, y: yAll)
                Capsule().fill(Color.black.opacity(0.85))
                    .frame(width: gap * 0.60, height: S * 0.012)
                    .position(x: S*0.5, y: yAll)

            case .sunglasses:
                let w = S * 0.16, h = S * 0.10, gap = S * 0.05
                let cxL = S*0.5 - (w/2 + gap/2)
                let cxR = S*0.5 + (w/2 + gap/2)
                temples(from: cxL - w/2, to: cxR + w/2, y: yAll)
                Capsule().fill(Color.black.opacity(0.85))
                    .frame(width: w, height: h).position(x: cxL, y: yAll)
                Capsule().fill(Color.black.opacity(0.85))
                    .frame(width: w, height: h).position(x: cxR, y: yAll)
                Capsule().fill(Color.black.opacity(0.85))
                    .frame(width: gap * 0.70, height: S * 0.012)
                    .position(x: S*0.5, y: yAll)
            }
        }
    }
}
