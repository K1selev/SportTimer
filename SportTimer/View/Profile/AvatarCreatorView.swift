//
//  AvatarCreatorView.swift
//  SportTimer
//
//  Created by Сергей Киселев on 21.11.2025.
//
import SwiftUI

struct AvatarCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AvatarCreatorViewModel()

    enum Tab: CaseIterable {
        case body, skin, eyes, glasses, shirt
        var title: String {
            switch self {
            case .body:     return "Тело"
            case .skin:     return "Кожа"
            case .eyes:     return "Глаза"
            case .glasses:  return "Очки"
            case .shirt:    return "Одежда"
            }
        }
    }

    var onDone: (UIImage) -> Void
    @State private var selected: Tab = .body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Превью
                AvatarRenderer(cfg: vm.cfg)
                    .frame(height: 320)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                // Лента категорий
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            CategoryPill(
                                title: tab.title,
                                isSelected: selected == tab
                            ) { selected = tab }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                Divider()

                // Сетка опций (фикс. высота ячеек — больше нет наслоений)
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        switch selected {

                        case .body:
                            // Порядок: 3 прямоугольника + 5 треугольников
                            let bodies: [BodyStyle] = [.rectS,.rectM,.rectL,.triA,.triB,.triC,.triD,.triE]
                            ForEach(bodies, id: \.self) { style in
                                SelectCell(selected: vm.cfg.body == style) {
                                    MiniFigurePreview(cfg: vm.cfg, overrideBody: style)
                                }
                                .onTapGesture { vm.cfg.body = style }
                            }

                        case .skin:
                            ForEach(Array(SkinTone.allCases.enumerated()), id: \.offset) { _, tone in
                                SelectCell(selected: vm.cfg.skin == tone) {
                                    Circle().fill(tone.color)
                                }
                                .onTapGesture { vm.cfg.skin = tone }
                            }

                        case .eyes:
                            ForEach(Array(EyeStyle.allCases.enumerated()), id: \.offset) { _, e in
                                SelectCell(selected: vm.cfg.eyes == e, height: 60) {
                                    EyesMiniPreview(style: e)
                                }
                                .onTapGesture { vm.cfg.eyes = e }
                            }

                        case .glasses:
                            ForEach(Array(Glasses.allCases.enumerated()), id: \.offset) { _, g in
                                SelectCell(selected: vm.cfg.glasses == g) {
                                    GlassesMiniPreview(style: g)
                                }
                                .onTapGesture { vm.cfg.glasses = g }
                            }

                        case .shirt:
                            ForEach(Array(Shirt.allCases.enumerated()), id: \.offset) { _, s in
                                SelectCell(selected: vm.cfg.shirt == s) {
                                    RoundedRectangle(cornerRadius: 10).fill(s.color)
                                }
                                .onTapGesture { vm.cfg.shirt = s }
                            }
                        }
                    }
                    .padding(16)
                }

                // Нижняя панель
                HStack(spacing: 12) {
                    Button { vm.randomize(withoutHairAndMustache: true) } label: {
                        Label("Случайно", systemImage: "shuffle")
                    }
                    .buttonStyle(.bordered)

                    Button { vm.reset(withoutHairAndMustache: true) } label: {
                        Label("Сброс", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Готово") {
                        onDone(vm.exportImage())
                        dismiss()
                    }
                    .buttonStyle(PrimaryGradientButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Создайте аватар")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
            .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Мини-превью и карточки

private struct MiniFigurePreview: View {
    var cfg: AvatarConfig
    var overrideBody: BodyStyle?

    var body: some View {
        AvatarRenderer(cfg: {
            var c = cfg
            if let b = overrideBody { c.body = b }
            return c
        }())
        .frame(maxWidth: .infinity)
        .frame(height: 86)        // фикс. высота ячейки
        .clipped()
    }
}

private struct GlassesMiniPreview: View {
    let style: Glasses

    var body: some View {
        ZStack {
            AvatarTheme.bg
            switch style {
            case .none:
                EmptyView()

            case .round:
                HStack(spacing: 8) {
                    Circle().stroke(Color.black.opacity(0.85), lineWidth: 3)
                        .frame(width: 28, height: 28)
                    Circle().stroke(Color.black.opacity(0.85), lineWidth: 3)
                        .frame(width: 28, height: 28)
                }
                .overlay(
                    Capsule().fill(Color.black.opacity(0.85))
                        .frame(width: 16, height: 3)
                )
                // короткие дужки
                .overlay(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.8))
                        .frame(width: 18, height: 3).offset(x: -22)
                }
                .overlay(alignment: .trailing) {
                    Capsule().fill(Color.black.opacity(0.8))
                        .frame(width: 18, height: 3).offset(x: 22)
                }

            case .square:
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black.opacity(0.85), lineWidth: 3)
                        .frame(width: 30, height: 24)
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black.opacity(0.85), lineWidth: 3)
                        .frame(width: 30, height: 24)
                }
                .overlay(
                    Capsule().fill(Color.black.opacity(0.85))
                        .frame(width: 18, height: 3)
                )
                .overlay(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.8))
                        .frame(width: 18, height: 3).offset(x: -24)
                }
                .overlay(alignment: .trailing) {
                    Capsule().fill(Color.black.opacity(0.8))
                        .frame(width: 18, height: 3).offset(x: 24)
                }

            case .sunglasses:
                HStack(spacing: 10) {
                    Capsule().fill(Color.black.opacity(0.85))
                        .frame(width: 34, height: 16)
                    Capsule().fill(Color.black.opacity(0.85))
                        .frame(width: 34, height: 16)
                }
                .overlay(
                    Capsule().fill(Color.black.opacity(0.85))
                        .frame(width: 20, height: 3)
                )
                .overlay(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.8))
                        .frame(width: 20, height: 3).offset(x: -26)
                }
                .overlay(alignment: .trailing) {
                    Capsule().fill(Color.black.opacity(0.8))
                        .frame(width: 20, height: 3).offset(x: 26)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


private struct EyesMiniPreview: View {
    let style: EyeStyle
    var body: some View {
        ZStack {
            AvatarTheme.bg
            switch style {
            case .normal:
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(.white)
                            .frame(width: 26, height: 20)
                        Circle().fill(.black).frame(width: 9)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(.white)
                            .frame(width: 26, height: 20)
                        Circle().fill(.black).frame(width: 9)
                    }
                }
            case .happy:
                HStack(spacing: 12) {
                    Circle().stroke(lineWidth: 2).frame(width: 18, height: 18)
                    Circle().stroke(lineWidth: 2).frame(width: 18, height: 18)
                }
            case .sleepy:
                HStack(spacing: 16) {
                    Capsule().fill(.black).frame(width: 16, height: 3)
                    Capsule().fill(.black).frame(width: 16, height: 3)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)                 // компактная фикс. высота
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}



// Категория-пилюля
private struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(colors: [AvatarTheme.blue, AvatarTheme.purple],
                                                 startPoint: .leading, endPoint: .trailing))
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// Универсальная ячейка
private struct SelectCell<Content: View>: View {
    var selected: Bool
    var height: CGFloat = 86
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            if selected {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(colors: [AvatarTheme.blue, AvatarTheme.purple],
                                           startPoint: .leading, endPoint: .trailing),
                            lineWidth: 3)
            }
        }
        .frame(height: height)
    }
}
