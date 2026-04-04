import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    let survey: UserSurvey
    let analysis: AnalysisResult

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Score
                    ScoreRingView(score: analysis.overallScore)
                        .padding(.top, 8)

                    // Current parameters
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Сейчас")
                            .font(.system(size: 16, weight: .semibold))

                        ProfileMetricRow(icon: "bed.double.fill", color: .indigo,
                                         label: "Сон", value: "\(survey.sleepHours) ч",
                                         target: "7-8 ч")
                        ProfileMetricRow(icon: "bolt.fill", color: .yellow,
                                         label: "Энергия", value: "\(survey.energyLevel) из 5",
                                         target: "4-5")
                        ProfileMetricRow(icon: "flame.fill", color: .red,
                                         label: "Стресс", value: "\(survey.stressLevel) из 5",
                                         target: "1-2")
                        ProfileMetricRow(icon: "iphone", color: .blue,
                                         label: "Телефон", value: "\(survey.phoneHoursPerDay) ч/день",
                                         target: "< 2 ч")
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                    // Resources
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ресурсы")
                            .font(.system(size: 16, weight: .semibold))

                        HStack(spacing: 8) {
                            if survey.hasStudy == true {
                                ProfileBadge(text: "Учёба", color: .blue)
                            }
                            if survey.hasWork == true {
                                ProfileBadge(text: "Работа", color: .green)
                            }
                            if survey.hasDebts == true {
                                ProfileBadge(text: "Долги", color: .red)
                            }
                            if survey.hasStudy != true && survey.hasWork != true {
                                ProfileBadge(text: "Свободное время", color: .purple)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                    // Strength + Opportunity from analysis
                    AnalysisCardView(card: analysis.strength)
                        .padding(.horizontal, 24)

                    AnalysisCardView(card: analysis.opportunity)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("Профиль")
        }
    }
}

// MARK: - Metric Row

struct ProfileMetricRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    let target: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 28)

            Text(label)
                .font(.system(size: 15))
                .frame(width: 72, alignment: .leading)

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))

            Spacer()

            Text(target)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Badge

struct ProfileBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    let survey = UserSurvey(
        hasStudy: true,
        hasWork: true,
        hasDebts: false,
        phoneHoursPerDay: 5,
        energyLevel: 2,
        stressLevel: 4,
        sleepHours: 6
    )
    ProfileView(survey: survey, analysis: AnalysisEngine.analyze(survey))
}
