//
//  ContentView.swift
//  greatness
//
//  Created by Сулейман Курбанов on 31.03.2026.
//

import SwiftUI

enum AppScreen {
    case welcome
    case survey
    // case analysis 
}

struct ContentView: View {
    @State private var screen: AppScreen = .welcome

    var body: some View {
        switch screen {
        case .welcome:
            WelcomeView {
                withAnimation {
                    screen = .survey
                }
            }
        case .survey:
            SurveyView { survey in
                print("Survey done:", survey)
            }
        }
    }
}

#Preview {
    ContentView()
}
