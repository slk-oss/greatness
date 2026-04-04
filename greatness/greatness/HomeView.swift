import SwiftUI
import Combine

// MARK: - Task Tracker

class TaskTracker: ObservableObject {
    let days: [DayPlan]
    @Published var completions: [Int: Set<Int>] = [:] { didSet { save() } }
    @Published var currentDay: Int = 1 { didSet { save() } }
    @Published var notes: [Int: String] = [:] { didSet { save() } }

    init(survey: UserSurvey) {
        self.days = PlanData.generate(from: survey)
        load()
    }

    func isCompleted(day: Int, taskIndex: Int) -> Bool {
        completions[day]?.contains(taskIndex) ?? false
    }

    func toggle(day: Int, taskIndex: Int) {
        var set = completions[day] ?? []
        if set.contains(taskIndex) {
            set.remove(taskIndex)
        } else {
            set.insert(taskIndex)
        }
        completions[day] = set
    }

    var todayPlan: DayPlan? {
        days.first { $0.day == currentDay }
    }

    var totalTaskCount: Int {
        days.reduce(0) { $0 + $1.tasks.count }
    }

    var totalCompleted: Int {
        completions.values.reduce(0) { $0 + $1.count }
    }

    var completedDaysCount: Int {
        days.filter { day in
            let done = completions[day.day]?.count ?? 0
            return done >= day.tasks.count
        }.count
    }

    func isDayFullyCompleted(_ dayNum: Int) -> Bool {
        guard let plan = days.first(where: { $0.day == dayNum }) else { return false }
        return (completions[dayNum]?.count ?? 0) >= plan.tasks.count
    }

    func advanceDay() {
        if currentDay < days.count {
            withAnimation { currentDay += 1 }
        }
    }

    // MARK: - Persistence

    private func save() {
        let ud = UserDefaults.standard
        ud.set(currentDay, forKey: "tracker_currentDay")

        let compDict: [String: [Int]] = completions.reduce(into: [:]) { r, p in
            r[String(p.key)] = Array(p.value)
        }
        if let data = try? JSONEncoder().encode(compDict) {
            ud.set(data, forKey: "tracker_completions")
        }

        let notesDict: [String: String] = notes.reduce(into: [:]) { r, p in
            r[String(p.key)] = p.value
        }
        if let data = try? JSONEncoder().encode(notesDict) {
            ud.set(data, forKey: "tracker_notes")
        }
    }

    private func load() {
        let ud = UserDefaults.standard
        let savedDay = ud.integer(forKey: "tracker_currentDay")
        if savedDay > 0 { currentDay = savedDay }

        if let data = ud.data(forKey: "tracker_completions"),
           let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data) {
            completions = decoded.reduce(into: [:]) { r, p in
                if let key = Int(p.key) { r[key] = Set(p.value) }
            }
        }

        if let data = ud.data(forKey: "tracker_notes"),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            notes = decoded.reduce(into: [:]) { r, p in
                if let key = Int(p.key) { r[key] = p.value }
            }
        }
    }

    func archiveAndReset() {
        let ud = UserDefaults.standard
        let cycle = ud.integer(forKey: "current_cycle")

        // Archive current cycle
        if let compData = ud.data(forKey: "tracker_completions") {
            ud.set(compData, forKey: "cycle_\(cycle)_completions")
        }
        if let notesData = ud.data(forKey: "tracker_notes") {
            ud.set(notesData, forKey: "cycle_\(cycle)_notes")
        }

        // Clear current tracker data
        ud.removeObject(forKey: "tracker_completions")
        ud.removeObject(forKey: "tracker_notes")
        ud.removeObject(forKey: "tracker_currentDay")
        ud.removeObject(forKey: "saved_survey")

        // Increment cycle
        ud.set(cycle + 1, forKey: "current_cycle")
    }
}

// MARK: - HomeView

struct HomeView: View {
    @StateObject private var tracker: TaskTracker
    let survey: UserSurvey
    var onNewCycle: (() -> Void)?

    init(survey: UserSurvey, onNewCycle: (() -> Void)? = nil) {
        self.survey = survey
        self.onNewCycle = onNewCycle
        _tracker = StateObject(wrappedValue: TaskTracker(survey: survey))
    }

    private var analysis: AnalysisResult {
        AnalysisEngine.analyze(survey)
    }

    var body: some View {
        TabView {
            ProfileView(survey: survey, analysis: analysis)
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }

            TodayView(tracker: tracker, userName: survey.name, onNewCycle: {
                tracker.archiveAndReset()
                onNewCycle?()
            })
                .tabItem {
                    Label("Сегодня", systemImage: "checkmark.circle.fill")
                }

            PlanTabView(tracker: tracker)
                .tabItem {
                    Label("План", systemImage: "calendar")
                }

            HistoryView(tracker: tracker)
                .tabItem {
                    Label("История", systemImage: "clock.fill")
                }

            StatsView(tracker: tracker, survey: survey)
                .tabItem {
                    Label("Прогресс", systemImage: "chart.bar.fill")
                }
        }
        .onAppear {
            NotificationManager.shared.requestPermission()
            NotificationManager.shared.scheduleDailyReminder(hour: 21, minute: 0)
        }
    }
}

// MARK: - Plan Tab

struct PlanTabView: View {
    @ObservedObject var tracker: TaskTracker

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(tracker.days) { day in
                        PlanTabDayRow(
                            day: day,
                            isCurrentDay: day.day == tracker.currentDay,
                            isCompleted: tracker.isDayFullyCompleted(day.day),
                            completions: tracker.completions[day.day] ?? []
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationTitle("10-дневный план")
        }
    }
}

struct PlanTabDayRow: View {
    let day: DayPlan
    let isCurrentDay: Bool
    let isCompleted: Bool
    let completions: Set<Int>
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {

            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.green :
                                  isCurrentDay ? Color.primary : Color(.systemGray5))
                            .frame(width: 36, height: 36)
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(day.day)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(isCurrentDay ? Color(.systemBackground) : .primary)
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

                    if isCurrentDay {
                        Text("сейчас")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.primary)
                            .clipShape(Capsule())
                    }

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
                }
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            if isCurrentDay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1.5)
            }
        }
    }
}

#Preview {
    HomeView(survey: UserSurvey(
        name: "Сулейман",
        hasStudy: true,
        hasWork: true,
        hasDebts: false,
        phoneHoursPerDay: 5,
        energyLevel: 2,
        stressLevel: 4,
        sleepHours: 6
    ))
}
