//
//  MVPApp.swift
//  MVP
//
//  Created by Marlon Becker on 03.02.25.
//

// MVPApp.swift
import SwiftUI

@main
struct MVPApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if appState.isLoggedIn {
                    if appState.isOnboarded {
                        HomeView()
                    } else {
                        OnboardingView().environmentObject(appState)
                    }
                } else {
                    LoginView().environmentObject(appState)
                }
            }
        }
    }
}

