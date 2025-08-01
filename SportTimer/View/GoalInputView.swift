import SwiftUI

struct GoalInputView: View {
    @Environment(\.dismiss) var dismiss
    @State var tempGoals: [WorkoutGoal]
    var onSave: ([WorkoutGoal]) -> Void

    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Form {
                    ForEach($tempGoals, id: \.type) { $goal in
                        HStack {
                            Text(goal.type)
                            Spacer()
                            TextField("Часы", value: $goal.targetHours, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                            Text("ч")
                        }
                    }
                }

                if isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    AppButton(title: "Сохранить", color: .green) {
                        saveGoals()
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
            .mainBackground()
            .navigationTitle("Цели на месяц")
        }
    }

    private func saveGoals() {
        isSaving = true

        // Имитация задержки сохранения, если надо
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onSave(tempGoals)
            isSaving = false
            dismiss()
        }
    }
}
