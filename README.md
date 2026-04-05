# greatness

> You're not broken. You just lost your rhythm.

![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue?style=flat-square&logo=apple)
![Platform](https://img.shields.io/badge/iOS-17.0+-lightgrey?style=flat-square&logo=apple)
![Status](https://img.shields.io/badge/status-in%20development-yellow?style=flat-square)

---

## What is this

**greatness** is an iOS app for people who want to take back control of their lives.

Not another habit tracker with streaks and badges.  
Not a motivational app flooding you with quotes from famous people.  
Not a planner that makes you feel guilty for every missed day.

Just an honest tool. You answer a few questions — the app analyzes your situation and gives you a realistic 10-day roadmap. Small actions. Every day.

Because **one small action today beats a perfect plan for the month**.

---

## How it works

```
Diagnosis → Analysis → 10-Day Plan → Daily Tasks → Progress
```

1. **Diagnosis** — a short survey: work, study, sleep, energy, stress, screen time
2. **Analysis** — the app finds your strength, weak zone, main risk, and nearest opportunity
3. **Plan** — a personalized 10-day roadmap adapted to your situation
4. **Tasks** — 2–3 actions per day. Not 20. Not 50. Two or three.
5. **Progress** — track your momentum, stats, and history for each day

---

## Screens

| Screen | Description |
|--------|-------------|
| 🏠 Profile | Your data, current state, what to aim for |
| ✅ Today | Daily tasks with completion tracking |
| 📅 Plan | Full 10-day roadmap with per-day progress |
| 📊 Stats | Statistics: days, tasks completed, completion rate |
| 🕐 History | Archive of past days and daily notes |

---

## Tech Stack

- **Swift 5.9** — primary language
- **SwiftUI** — declarative UI framework
- **Combine** — reactive state management
- **UserDefaults** — local data persistence
- **UserNotifications** — local push notifications
- **MVVM** — architecture pattern

Zero third-party dependencies. No backend. Everything stays on device.

---

## Project Structure

```
greatness/
├── WelcomeView.swift          # Onboarding welcome screen
├── SurveyView.swift           # Survey flow + UserSurvey model
├── AnalysisView.swift         # Analysis screen + AnalysisEngine
├── PlanView.swift             # 10-day plan overview
├── HomeView.swift             # TabView root + TaskTracker
├── TodayView.swift            # Today's tasks
├── ProfileView.swift          # User profile screen
├── StatsView.swift            # Progress statistics
├── HistoryView.swift          # Past days history
├── NotificationManager.swift  # Local notifications
└── ContentView.swift          # App navigation (AppScreen enum)
```

---

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/slk-oss/greatness.git
```

2. Open `greatness.xcodeproj` in Xcode

3. Select a simulator or your device

4. Hit `Cmd+R`

Requirements: **Xcode 15+**, **iOS 17.0+**

---

## Philosophy

Most productivity apps make one fundamental mistake — they're optimized for the perfect user. Someone who never gets tired, never skips a day, and is always motivated.

That person doesn't exist.

**greatness** is built around a real human being. One who sometimes fails to complete tasks. Who gets exhausted. Who starts over. And that's okay — what matters is that they keep moving forward, even if just 0.25% a day.

```
0.25% per day = +150% per year
```

---

## Roadmap

- [x] Welcome Screen
- [x] Survey & diagnosis
- [x] Analysis Engine
- [x] 10-day personalized plan
- [x] Daily task tracking
- [x] User profile screen
- [x] Statistics & progress
- [x] Day history
- [x] Local notifications
- [x] Data persistence (UserDefaults)
- [ ] New cycle after 10 days
- [ ] Home screen widget
- [ ] Progress export

---

## Author

Built by **Suleiman Kurbanov** ([@slk-oss](https://github.com/slk-oss))

---

*You can improve 0.25% every day. Start today.*
