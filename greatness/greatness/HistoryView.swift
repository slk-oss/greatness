import SwiftUI
import Combine

// MARK: - HistoryView

struct HistoryView: View {
    @ObservedObject var tracker: TaskTracker

    private var pastDays: [DayPlan] {
        tracker.days.filter { $0.day < tracker.currentDay }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if pastDays.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 40))
                            .foregroundStyle(.tertiary)
                        Text("Пока нет истории")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text("Завершённые дни появятся здесь")
                            .font(.system(size: 14))
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    VStack(spacing: 8) {
                        ForEach(pastDays) { day in
                            HistoryDayCard(
                                day: day,
                                completions: tracker.completions[day.day] ?? [],
                                note: tracker.notes[day.day]
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("История")
        }
    }
}

// MARK: - History Day Card

struct HistoryDayCard: View {
    let day: DayPlan
    let completions: Set<Int>
    let note: String?
    @State private var isExpanded = false

    private var completionPercent: Int {
        guard day.tasks.count > 0 else { return 0 }
        return Int(Double(completions.count) / Double(day.tasks.count) * 100)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    // Completion indicator
                    ZStack {
                        Circle()
                            .fill(completions.count >= day.tasks.count ? Color.green : Color.orange)
                            .frame(width: 36, height: 36)
                        if completions.count >= day.tasks.count {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(completionPercent)%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("День \(day.day)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                        Text("\(completions.count)/\(day.tasks.count) задач")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider().padding(.horizontal, 16)

                    ForEach(Array(day.tasks.enumerated()), id: \.offset) { index, task in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: completions.contains(index) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 14))
                                .foregroundStyle(completions.contains(index) ? .green : .secondary)
                                .padding(.top, 1)
                            Text(task)
                                .font(.system(size: 15))
                                .foregroundStyle(completions.contains(index) ? .secondary : .primary)
                                .strikethrough(completions.contains(index))
                                .lineSpacing(2)
                        }
                        .padding(.horizontal, 16)
                    }

                    // Note if present
                    if let note, !note.isEmpty {
                        Divider().padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Заметка")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            Text(note)
                                .font(.system(size: 14))
                                .foregroundStyle(.primary)
                                .lineSpacing(3)
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
    let tracker = TaskTracker(survey: UserSurvey(
        name: "Сулейман",
        hasStudy: true,
        hasWork: true,
        hasDebts: false,
        phoneHoursPerDay: 5,
        energyLevel: 2,
        stressLevel: 4,
        sleepHours: 6
    ))
    HistoryView(tracker: tracker)
}
