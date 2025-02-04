// MVPApp.swift
import SwiftUI

@main
struct MVPApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                if appState.isOnboarded {
                    TabView {
                        FeedView()
                            .tabItem { Label("Feed", systemImage: "list.bullet") }
                        EventFeedView()
                            .tabItem { Label("Events", systemImage: "calendar") }
                        ProfileView()
                            .tabItem { Label("Profile", systemImage: "person.circle") }
                    }
                    .environmentObject(appState)
                } else {
                    OnboardingView().environmentObject(appState)
                }
            } else {
                LoginView().environmentObject(appState)
            }
        }
    }
}
