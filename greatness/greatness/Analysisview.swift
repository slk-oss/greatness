//
//  Analysisview.swift
//  greatness
//
//  Created by Сулейман Курбанов on 03.04.2026.
//

import SwiftUI
import Combine

// MARK: - Analysis Result Model

struct AnalysisResult {
    let strength: AnalysisCard
    let weakness: AnalysisCard
    let risk: AnalysisCard
    let opportunity: AnalysisCard
    let overallScore: Int  // 0–100
}

struct AnalysisCard: Identifiable {
    let id = UUID()
    let icon: String       
    let label: String      // Тип: "Сильная сторона" и т.д.
    let title: String
    let body: String
    let color: Color
}

// MARK: - Analysis Engine

struct AnalysisEngine {

    static func analyze(_ survey: UserSurvey) -> AnalysisResult {

        let strength = buildStrength(survey)
        let weakness = buildWeakness(survey)
        let risk     = buildRisk(survey)
        let opportunity = buildOpportunity(survey)
        let score    = buildScore(survey)

        return AnalysisResult(
            strength: strength,
            weakness: weakness,
            risk: risk,
            opportunity: opportunity,
            overallScore: score
        )
    }

    // MARK: Strength

    private static func buildStrength(_ s: UserSurvey) -> AnalysisCard {
        let title: String
        let body: String

        if s.hasWork == true && s.hasStudy == true {
            title = "Ты совмещаешь учёбу и работу"
            body  = "Это требует дисциплины. Значит, ресурс есть — нужно его направить."
        } else if s.hasWork == true {
            title = "У тебя есть доход"
            body  = "Финансовая база даёт свободу принимать решения без паники."
        } else if s.hasStudy == true {
            title = "Ты инвестируешь в себя"
            body  = "Учёба — это актив. Каждый день ты становишься чуть дороже."
        } else {
            title = "У тебя есть время"
            body  = "Свободное время — редкий ресурс. Вопрос только в том, как его использовать."
        }

        return AnalysisCard(
            icon: "bolt.fill",
            label: "Сильная сторона",
            title: title,
            body: body,
            color: .green
        )
    }

    // MARK: Weakness

    private static func buildWeakness(_ s: UserSurvey) -> AnalysisCard {
        let title: String
        let body: String

        if s.phoneHoursPerDay >= 6 {
            title = "Телефон забирает день"
            body  = "\(s.phoneHoursPerDay) часов экрана — это \(s.phoneHoursPerDay * 7) часов в неделю. Больше рабочего дня."
        } else if s.sleepHours < 6 {
            title = "Хронический недосып"
            body  = "Меньше 6 часов сна — снижает концентрацию, волю и настроение. Всё остальное работает хуже."
        } else if s.energyLevel <= 2 {
            title = "Низкий уровень энергии"
            body  = "Когда энергии мало, даже простые задачи кажутся тяжёлыми. Это первое, что нужно восстановить."
        } else if s.stressLevel >= 4 {
            title = "Высокий фоновый стресс"
            body  = "Хронический стресс блокирует принятие решений и съедает мотивацию."
        } else {
            title = "Нет чёткой структуры дня"
            body  = "Без структуры энергия расходуется хаотично — результат есть, но мог быть лучше."
        }

        return AnalysisCard(
            icon: "exclamationmark.triangle.fill",
            label: "Слабая зона",
            title: title,
            body: body,
            color: .orange
        )
    }

    // MARK: Risk

    private static func buildRisk(_ s: UserSurvey) -> AnalysisCard {
        let title: String
        let body: String

        if s.hasDebts == true && s.energyLevel <= 2 {
            title = "Долги при низкой энергии — опасно"
            body  = "Финансовое давление при истощении ведёт к импульсивным решениям. Сначала — стабилизация."
        } else if s.stressLevel >= 4 && s.sleepHours < 6 {
            title = "Стресс + недосып = выгорание"
            body  = "Эта комбинация ускоряет истощение. Без вмешательства станет хуже."
        } else if s.phoneHoursPerDay >= 5 && s.energyLevel <= 2 {
            title = "Пассивное потребление вместо восстановления"
            body  = "Телефон создаёт ощущение отдыха, но не восстанавливает. Энергия продолжает падать."
        } else {
            title = "Потеря импульса"
            body  = "Без регулярных маленьких побед мотивация постепенно угасает. Нужна видимая точка роста."
        }

        return AnalysisCard(
            icon: "shield.lefthalf.filled",
            label: "Главный риск",
            title: title,
            body: body,
            color: .red
        )
    }

    // MARK: Opportunity

    private static func buildOpportunity(_ s: UserSurvey) -> AnalysisCard {
        let title: String
        let body: String

        if s.phoneHoursPerDay >= 4 {
            let freed = s.phoneHoursPerDay - 2
            title = "Освободи \(freed) часа в день"
            body  = "Если сократить экранное время до 2 часов — у тебя появятся \(freed * 7) свободных часов в неделю."
        } else if s.sleepHours < 7 {
            title = "Добавь 1 час сна"
            body  = "Один дополнительный час сна резко улучшает концентрацию, настроение и волю уже через 3–5 дней."
        } else if s.energyLevel >= 3 && s.stressLevel <= 3 {
            title = "Ты в хорошей точке для старта"
            body  = "Энергия и стресс в норме. Сейчас — лучший момент начать стабильные действия."
        } else {
            title = "Маленькие победы меняют всё"
            body  = "Выполнение 2–3 простых задач в день запускает позитивную петлю. Начни с малого."
        }

        return AnalysisCard(
            icon: "arrow.up.right.circle.fill",
            label: "Ближайшая возможность",
            title: title,
            body: body,
            color: .blue
        )
    }

    // MARK: Score

    private static func buildScore(_ s: UserSurvey) -> Int {
        var score = 50

        // Энергия (макс +15)
        score += (s.energyLevel - 3) * 5

        // Сон
        if s.sleepHours >= 7 { score += 10 }
        else if s.sleepHours < 6 { score -= 10 }

        // Стресс
        if s.stressLevel <= 2 { score += 10 }
        else if s.stressLevel >= 4 { score -= 10 }

        // Телефон
        if s.phoneHoursPerDay <= 2 { score += 10 }
        else if s.phoneHoursPerDay >= 6 { score -= 10 }

        // Ресурсы
        if s.hasWork == true { score += 5 }
        if s.hasStudy == true { score += 5 }

        // Долги
        if s.hasDebts == true { score -= 5 }

        return max(10, min(score, 95))
    }
}

// MARK: - ViewModel

class AnalysisViewModel: ObservableObject {
    @Published var result: AnalysisResult
    @Published var isAnimated = false

    init(survey: UserSurvey) {
        self.result = AnalysisEngine.analyze(survey)
    }
}

// MARK: - AnalysisView

struct AnalysisView: View {
    @StateObject private var vm: AnalysisViewModel
    var onContinue: () -> Void

    init(survey: UserSurvey, onContinue: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: AnalysisViewModel(survey: survey))
        self.onContinue = onContinue
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Header
                VStack(spacing: 8) {
                    Text("Твоя картина")
                        .font(.system(size: 28, weight: .bold))
                    Text("На основе твоих ответов")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 32)

                // Score ring
                ScoreRingView(score: vm.result.overallScore)
                    .opacity(vm.isAnimated ? 1 : 0)
                    .scaleEffect(vm.isAnimated ? 1 : 0.8)
                    .animation(.spring(duration: 0.6), value: vm.isAnimated)

                // Cards
                VStack(spacing: 12) {
                    ForEach([
                        vm.result.strength,
                        vm.result.weakness,
                        vm.result.risk,
                        vm.result.opportunity
                    ]) { card in
                        AnalysisCardView(card: card)
                            .opacity(vm.isAnimated ? 1 : 0)
                            .offset(y: vm.isAnimated ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: vm.isAnimated)
                    }
                }
                .padding(.horizontal, 24)

                // CTA
                Button(action: onContinue) {
                    Text("Получить 10-дневный план")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation { vm.isAnimated = true }
        }
    }
}

// MARK: - Score Ring

struct ScoreRingView: View {
    let score: Int
    @State private var progress: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: progress)

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                    Text("из 100")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }

            Text(scoreLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(scoreColor)
        }
        .onAppear {
            progress = Double(score) / 100.0
        }
    }

    var scoreColor: Color {
        switch score {
        case 0..<40:  return .red
        case 40..<65: return .orange
        default:      return .green
        }
    }

    var scoreLabel: String {
        switch score {
        case 0..<40:  return "Требует внимания"
        case 40..<65: return "Есть потенциал"
        default:      return "Хорошая база"
        }
    }
}

// MARK: - Analysis Card

struct AnalysisCardView: View {
    let card: AnalysisCard

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: card.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(card.color)
                Text(card.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(card.color)
                    .textCase(.uppercase)
                    .kerning(0.5)
            }

            Text(card.title)
                .font(.system(size: 17, weight: .semibold))

            Text(card.body)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AnalysisView(
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
