import SwiftUI

@main
struct MVPApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                if appState.isOnboarded {
                    ContentView() // Neue Container-View, die den glassmorphischen Tabbar enthält
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
