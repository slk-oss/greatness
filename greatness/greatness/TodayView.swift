import SwiftUI

// MARK: - TodayView

struct TodayView: View {
    @ObservedObject var tracker: TaskTracker
    var userName: String = ""
    var onNewCycle: (() -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Day progress header
                    DayProgressHeader(tracker: tracker)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    // Tasks list
                    if let plan = tracker.todayPlan {
                        VStack(spacing: 0) {
                            ForEach(Array(plan.tasks.enumerated()), id: \.offset) { index, task in
                                TaskRowView(
                                    task: task,
                                    isCompleted: tracker.isCompleted(day: plan.day, taskIndex: index)
                                ) {
                                    withAnimation(.spring(duration: 0.3)) {
                                        tracker.toggle(day: plan.day, taskIndex: index)
                                    }
                                }

                                if index < plan.tasks.count - 1 {
                                    Divider()
                                        .padding(.leading, 56)
                                }
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)

                        // Day note
                        DayNoteView(tracker: tracker, day: plan.day)
                            .padding(.horizontal, 24)

                        // Navigation
                        if tracker.currentDay < 10 {
                            Button {
                                tracker.advanceDay()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Перейти к дню \(tracker.currentDay + 1)")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(tracker.isDayFullyCompleted(plan.day) ? Color.green : Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(.horizontal, 24)

                        } else if tracker.currentDay == 10 {
                            AllDoneView(onNewCycle: onNewCycle)
                                .padding(.horizontal, 24)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle(userName.isEmpty ? "День \(tracker.currentDay)" : "Привет, \(userName)")
        }
    }
}

// MARK: - Day Note

struct DayNoteView: View {
    @ObservedObject var tracker: TaskTracker
    let day: Int

    private var noteBinding: Binding<String> {
        Binding(
            get: { tracker.notes[day] ?? "" },
            set: { tracker.notes[day] = $0.isEmpty ? nil : $0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Заметка дня")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            TextEditor(text: noteBinding)
                .font(.system(size: 15))
                .frame(minHeight: 80, maxHeight: 140)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topLeading) {
                    if noteBinding.wrappedValue.isEmpty {
                        Text("Как прошёл день...")
                            .font(.system(size: 15))
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

// MARK: - Day Progress Header

struct DayProgressHeader: View {
    @ObservedObject var tracker: TaskTracker

    var progress: Double {
        Double(tracker.currentDay - 1) / 10.0
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("День \(tracker.currentDay) из 10")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(tracker.completedDaysCount) завершено")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            ProgressBarView(progress: progress)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Task Row

struct TaskRowView: View {
    let task: String
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.green : Color(.systemGray3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isCompleted {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text(task)
                    .font(.system(size: 16))
                    .foregroundStyle(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted, color: .secondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - All Done

struct AllDoneView: View {
    var onNewCycle: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text("10 дней завершены!")
                .font(.system(size: 22, weight: .bold))
            Text("Ты прошёл полный цикл.\nПора ставить новую цель.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if let onNewCycle {
                Button {
                    onNewCycle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Начать новый цикл")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
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
    TodayView(tracker: tracker, userName: "Сулейман")
}
