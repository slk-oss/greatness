//
//  PlanView.swift
//  greatness
//
//  Created by Сулейман Курбанов on 03.04.2026.
//

import SwiftUI
import Combine
// MARK: - Models

struct DayPlan: Identifiable {
    let id = UUID()
    let day: Int
    let tasks: [String]
}

struct PlanData {
    static func generate(from survey: UserSurvey) -> [DayPlan] {
        return [
            DayPlan(day: 1, tasks: [
                "Лечь до 23:30",
                survey.phoneHoursPerDay >= 4 ? "Убрать телефон за час до сна" : "Подготовить план на завтра",
                "Выполнить 1 важную задачу"
            ]),
            DayPlan(day: 2, tasks: [
                "20 минут движения",
                "Без соцсетей утром — первый час",
                "1 завершённое дело"
            ]),
            DayPlan(day: 3, tasks: [
                survey.sleepHours < 7 ? "Лечь на 30 минут раньше обычного" : "Сохранить режим сна",
                "Написать 3 вещи, за которые благодарен",
                "Убрать 1 источник отвлечения"
            ]),
            DayPlan(day: 4, tasks: [
                "30 минут без телефона днём",
                "Сделать что-то для здоровья",
                survey.hasWork == true ? "Закрыть 1 рабочую задачу" : "Потратить час на развитие"
            ]),
            DayPlan(day: 5, tasks: [
                "Промежуточный итог — что изменилось?",
                "Повторить лучшее действие из прошлых дней",
                "Лечь вовремя"
            ]),
            DayPlan(day: 6, tasks: [
                "Утренняя прогулка или зарядка",
                survey.hasStudy == true ? "1 час учёбы без отвлечений" : "1 час на личный проект",
                "Вечер без экрана — хотя бы 30 минут"
            ]),
            DayPlan(day: 7, tasks: [
                "День восстановления — не перегружать себя",
                "Сделать что-то приятное",
                "Записать 1 цель на следующую неделю"
            ]),
            DayPlan(day: 8, tasks: [
                "Ранний подъём — на 15 минут раньше обычного",
                "Убрать 1 лишнюю подписку или привычку",
                "Выполнить самую нелюбимую задачу первой"
            ]),
            DayPlan(day: 9, tasks: [
                "Повторить режим сна из дня 1",
                survey.hasDebts == true ? "Разобраться с одним финансовым вопросом" : "Отложить небольшую сумму",
                "20 минут чтения или подкаст"
            ]),
            DayPlan(day: 10, tasks: [
                "Оглянуться назад — 10 дней пройдено",
                "Написать что изменилось",
                "Поставить следующую цель на 10 дней"
            ])
        ]
    }
}

// MARK: - ViewModel

class PlanViewModel: ObservableObject {
    @Published var days: [DayPlan]
    @Published var expandedDay: Int? = 1

    init(survey: UserSurvey) {
        self.days = PlanData.generate(from: survey)
    }

    func toggle(day: Int) {
        withAnimation(.easeInOut(duration: 0.25)) {
            expandedDay = expandedDay == day ? nil : day
        }
    }
}

// MARK: - PlanView

struct PlanView: View {
    @StateObject private var vm: PlanViewModel
    var onContinue: () -> Void

    init(survey: UserSurvey, onContinue: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: PlanViewModel(survey: survey))
        self.onContinue = onContinue
    }

    var body: some View {
        VStack(spacing: 0) {

            // Header
            VStack(spacing: 6) {
                Text("Твой план")
                    .font(.system(size: 28, weight: .bold))
                Text("10 дней — 10 шагов вперёд")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 32)
            .padding(.bottom, 20)

            // Days list
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(vm.days) { day in
                        DayRowView(
                            day: day,
                            isExpanded: vm.expandedDay == day.day
                        ) {
                            vm.toggle(day: day.day)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }

            // CTA
            Button(action: onContinue) {
                Text("Начать выполнение")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .padding(.top, 8)
        }
    }
}

// MARK: - Day Row

struct DayRowView: View {
    let day: DayPlan
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            // Row header
            Button(action: onTap) {
                HStack {
                    // Day number badge
                    ZStack {
                        Circle()
                            .fill(isExpanded ? Color.primary : Color(.systemGray5))
                            .frame(width: 36, height: 36)
                        Text("\(day.day)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isExpanded ? Color(.systemBackground) : .primary)
                    }

                    Text("День \(day.day)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // Expanded tasks
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                        .padding(.horizontal, 16)

                    ForEach(day.tasks, id: \.self) { task in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "circle")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                            Text(task)
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                                .lineSpacing(2)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PlanView(
        survey: UserSurvey(
            hasStudy: true,
            hasWork: true,
            hasDebts: false,
            phoneHoursPerDay: 5,
            energyLevel: 2,
            stressLevel: 4,
            sleepHours: 6
        ),
        onContinue: {}
    )
}
