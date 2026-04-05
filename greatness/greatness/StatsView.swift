import SwiftUI

// MARK: - StatsView

struct StatsView: View {
    @ObservedObject var tracker: TaskTracker
    let survey: UserSurvey

    private var analysisResult: AnalysisResult {
        AnalysisEngine.analyze(survey)
    }

    var completionPercent: Double {
        guard tracker.totalTaskCount > 0 else { return 0 }
        return Double(tracker.totalCompleted) / Double(tracker.totalTaskCount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCardView(
                            value: "\(tracker.currentDay)",
                            label: "Текущий день",
                            icon: "calendar",
                            color: .blue
                        )
                        StatCardView(
                            value: "\(tracker.completedDaysCount)",
                            label: "Дней завершено",
                            icon: "checkmark.seal.fill",
                            color: .green
                        )
                        StatCardView(
                            value: "\(tracker.totalCompleted)",
                            label: "Задач выполнено",
                            icon: "checkmark.circle.fill",
                            color: .purple
                        )
                        StatCardView(
                            value: "\(tracker.totalTaskCount - tracker.totalCompleted)",
                            label: "Задач осталось",
                            icon: "clock.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 24)

                    // Overall progress bar
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Общий прогресс")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text("\(Int(completionPercent * 100))%")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                        ProgressBarView(progress: completionPercent)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                    // Analysis score
                    VStack(spacing: 16) {
                        HStack {
                            Text("Твой профиль")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        ScoreRingView(score: analysisResult.overallScore)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                    // Days breakdown
                    VStack(alignment: .leading, spacing: 0) {
                        Text("По дням")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                        ForEach(tracker.days) { day in
                            DayStatRow(
                                day: day,
                                completedCount: tracker.completions[day.day]?.count ?? 0,
                                isCurrent: day.day == tracker.currentDay
                            )

                            if day.day < tracker.days.count {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }

                        Spacer(minLength: 12)
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Прогресс")
        }
    }
}

// MARK: - Stat Card

struct StatCardView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Day Stat Row

struct DayStatRow: View {
    let day: DayPlan
    let completedCount: Int
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("День \(day.day)")
                .font(.system(size: 14, weight: isCurrent ? .semibold : .regular))
                .foregroundStyle(isCurrent ? .primary : .secondary)
                .frame(width: 64, alignment: .leading)

            HStack(spacing: 4) {
                ForEach(0..<day.tasks.count, id: \.self) { index in
                    Circle()
                        .fill(index < completedCount ? Color.green : Color(.systemGray5))
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()

            if isCurrent {
                Text("сейчас")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary)
                    .clipShape(Capsule())
            } else if completedCount >= day.tasks.count {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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
    let tracker = TaskTracker(survey: survey)
    StatsView(tracker: tracker, survey: survey)
}
