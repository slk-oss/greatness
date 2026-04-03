import SwiftUI

enum AppScreen {
    case welcome
    case survey
    case analysis(UserSurvey)
    case plan(UserSurvey)
    // case tasks — следующий шаг
}

struct ContentView: View {
    @State private var screen: AppScreen = .welcome

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
                    print("→ tasks screen, coming soon")
                }
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    ContentView()
}
