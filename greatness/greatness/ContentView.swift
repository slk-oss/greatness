import SwiftUI
import Combine

enum AppScreen {
    case welcome
    case survey
    case analysis(UserSurvey)
    case plan(UserSurvey)
    case tasks(UserSurvey)
}

struct ContentView: View {
    @State private var screen: AppScreen = .welcome

    init() {
        // Check for saved survey — skip onboarding
        if let data = UserDefaults.standard.data(forKey: "saved_survey"),
           let survey = try? JSONDecoder().decode(UserSurvey.self, from: data) {
            _screen = State(initialValue: .tasks(survey))
        }

        // Initialize cycle counter if first launch
        if UserDefaults.standard.integer(forKey: "current_cycle") == 0 {
            UserDefaults.standard.set(1, forKey: "current_cycle")
        }
    }

    var body: some View {
        Group {
            switch screen {
            case .welcome:
                WelcomeView {
                    withAnimation { screen = .survey }
                }
            case .survey:
                SurveyView { survey in
                    withAnimation { screen = .analysis(survey) }
                }
            case .analysis(let survey):
                AnalysisView(survey: survey) {
                    withAnimation { screen = .plan(survey) }
                }
            case .plan(let survey):
                PlanView(survey: survey) {
                    // Save survey to UserDefaults
                    if let data = try? JSONEncoder().encode(survey) {
                        UserDefaults.standard.set(data, forKey: "saved_survey")
                    }
                    withAnimation { screen = .tasks(survey) }
                }
            case .tasks(let survey):
                HomeView(survey: survey, onNewCycle: {
                    withAnimation { screen = .survey }
                })
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    ContentView()
}
