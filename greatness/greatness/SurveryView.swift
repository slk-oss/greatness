//
//  SurveryView.swift
//  greatness
//
//  Created by Сулейман Курбанов on 31.03.2026.
//

import SwiftUI
import Combine

// MARK: - Model

struct UserSurvey {
    // Ресурсы
    var hasStudy: Bool? = nil
    var hasWork: Bool? = nil

    // Деньги
    var hasDebts: Bool? = nil

    // Время
    var phoneHoursPerDay: Int = 3

    // Состояние
    var energyLevel: Int = 3     // 1–5
    var stressLevel: Int = 3     // 1–5
    var sleepHours: Int = 7      // часов
}

// MARK: - ViewModel

class SurveyViewModel: ObservableObject {
    @Published var survey = UserSurvey()
    @Published var currentStep = 0

    let totalSteps = 4

    var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }

    func next() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func back() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
}

// MARK: - Main View

struct SurveyView: View {
    @StateObject private var vm = SurveyViewModel()
    var onComplete: (UserSurvey) -> Void

    var body: some View {
        VStack(spacing: 0) {

            // Progress bar
            ProgressBarView(progress: vm.progress)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            // Step counter
            Text("Шаг \(vm.currentStep + 1) из \(vm.totalSteps)")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.tertiary)
                .padding(.top, 8)

            // Step content
            Group {
                switch vm.currentStep {
                case 0: StepResourcesView(survey: $vm.survey)
                case 1: StepMoneyView(survey: $vm.survey)
                case 2: StepTimeView(survey: $vm.survey)
                case 3: StepStateView(survey: $vm.survey)
                default: EmptyView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: vm.currentStep)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Navigation buttons
            HStack(spacing: 12) {
                if vm.currentStep > 0 {
                    Button("Назад") {
                        vm.back()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button(vm.currentStep == vm.totalSteps - 1 ? "Готово" : "Далее") {
                    if vm.currentStep == vm.totalSteps - 1 {
                        onComplete(vm.survey)
                    } else {
                        vm.next()
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Progress Bar

struct ProgressBarView: View {
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Step 1: Ресурсы

struct StepResourcesView: View {
    @Binding var survey: UserSurvey

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            SurveyTitle("Расскажи о своих ресурсах")

            SurveyToggleRow(
                title: "Я учусь",
                subtitle: "Учёба, курсы, университет",
                isOn: Binding(
                    get: { survey.hasStudy ?? false },
                    set: { survey.hasStudy = $0 }
                )
            )

            SurveyToggleRow(
                title: "Я работаю",
                subtitle: "Основная или подработка",
                isOn: Binding(
                    get: { survey.hasWork ?? false },
                    set: { survey.hasWork = $0 }
                )
            )

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
}

// MARK: - Step 2: Деньги

struct StepMoneyView: View {
    @Binding var survey: UserSurvey

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            SurveyTitle("Финансовая ситуация")

            SurveyToggleRow(
                title: "Есть долги",
                subtitle: "Кредиты, займы у друзей",
                isOn: Binding(
                    get: { survey.hasDebts ?? false },
                    set: { survey.hasDebts = $0 }
                )
            )

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
}

// MARK: - Step 3: Время

struct StepTimeView: View {
    @Binding var survey: UserSurvey

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            SurveyTitle("Как ты тратишь время?")

            VStack(alignment: .leading, spacing: 12) {
                Text("Часов в телефоне в день")
                    .font(.system(size: 15, weight: .medium))

                HStack {
                    Text("\(survey.phoneHoursPerDay) ч")
                        .font(.system(size: 22, weight: .semibold, design: .monospaced))
                        .frame(width: 60)

                    Slider(value: Binding(
                        get: { Double(survey.phoneHoursPerDay) },
                        set: { survey.phoneHoursPerDay = Int($0) }
                    ), in: 0...12, step: 1)
                }

                Text(phoneComment)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }

    var phoneComment: String {
        switch survey.phoneHoursPerDay {
        case 0...2: return "Отличный контроль 💪"
        case 3...4: return "Умеренно, есть пространство"
        case 5...6: return "Много — стоит обратить внимание"
        default:    return "Критично — телефон забирает день"
        }
    }
}

// MARK: - Step 4: Состояние

struct StepStateView: View {
    @Binding var survey: UserSurvey

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SurveyTitle("Как ты сейчас?")

            SurveyScaleRow(
                title: "Уровень энергии",
                value: $survey.energyLevel,
                labels: ("😴 Ноль", "🔥 Полон сил")
            )

            SurveyScaleRow(
                title: "Уровень стресса",
                value: $survey.stressLevel,
                labels: ("😌 Спокойно", "😤 Зашкаливает")
            )

            VStack(alignment: .leading, spacing: 12) {
                Text("Часов сна в сутки")
                    .font(.system(size: 15, weight: .medium))

                HStack {
                    Text("\(survey.sleepHours) ч")
                        .font(.system(size: 22, weight: .semibold, design: .monospaced))
                        .frame(width: 60)

                    Slider(value: Binding(
                        get: { Double(survey.sleepHours) },
                        set: { survey.sleepHours = Int($0) }
                    ), in: 3...12, step: 1)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
}

// MARK: - Reusable Components

struct SurveyTitle: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .bold))
    }
}

struct SurveyToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SurveyScaleRow: View {
    let title: String
    @Binding var value: Int
    let labels: (String, String)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .medium))

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(i <= value ? Color.primary : Color(.systemGray5))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("\(i)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(i <= value ? Color(.systemBackground) : .secondary)
                        )
                        .onTapGesture { value = i }
                }
            }

            HStack {
                Text(labels.0)
                Spacer()
                Text(labels.1)
            }
            .font(.system(size: 12))
            .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SurveyView(onComplete: { _ in })
}
