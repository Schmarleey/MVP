import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .feed
    @Namespace private var buttonNamespace
    @State private var showCreateInTabBar: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .feed:
                    FeedView().environmentObject(appState)
                case .events:
                    EventFeedView().environmentObject(appState)
                case .profile:
                    ProfileView().environmentObject(appState)
                }
            }
            .ignoresSafeArea()
            .overlay(
                SimpleGlassmorphicTabBar(selectedTab: $selectedTab,
                                          showCreateInTabBar: $showCreateInTabBar,
                                          namespace: buttonNamespace)
                    .environmentObject(appState),
                alignment: .bottom
            )
        }
        .onAppear {
            // Unabhängig von den anderen Inhalten: Nach 2 Sekunden wird der Create-Button in der Tab-Bar aktiviert.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.spring()) {
                    showCreateInTabBar = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
