import SwiftUI

struct GoalInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State var tempGoals: [WorkoutGoal]
    var onSave: ([WorkoutGoal]) -> Void

    @State private var isSaving = false

    init(tempGoals: [WorkoutGoal], onSave: @escaping ([WorkoutGoal]) -> Void) {
        if tempGoals.isEmpty {
            let defaults: [WorkoutGoal] = WorkoutType.allCases.map { t in
                WorkoutGoal(type: t.rawValue, targetHours: Self.defaultHours(for: t))
            }
            _tempGoals = State(initialValue: defaults)
        } else {
            _tempGoals = State(initialValue: tempGoals)
        }
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Form {
                    Section("Цели по видам тренировок (часы в месяц)") {
                        ForEach($tempGoals, id: \.type) { $goal in
                            HStack(spacing: 12) {
                                Text(goal.type)
                                Spacer()
                                TextField("Часы", value: $goal.targetHours, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 70)
                                Text("ч").foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                if isSaving {
                    ProgressView().progressViewStyle(.circular)
                } else {
                    Button("Сохранить") { saveGoals() }
                        .buttonStyle(PrimaryGradientButtonStyle())
                        .padding(.horizontal)
                }

                Spacer(minLength: 12)
            }
            .navigationTitle("Цели на месяц")
            .background(Color(.systemBackground).ignoresSafeArea())
        }
    }

    private func saveGoals() {
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSave(tempGoals)
            isSaving = false
            dismiss()
        }
    }
    private static func defaultHours(for type: WorkoutType) -> Double {
        switch type {
        case .cardio:   return 8
        case .strength: return 10
        case .swimming: return 6
        case .yoga:     return 6
        case .other:    return 4
        }
    }
}
