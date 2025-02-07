import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .feed
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Anzeigen der ausgewählten View
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
            
            // Glassmorphische Tabbar am unteren Rand
            VStack {
                Spacer()
                GlassmorphicTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
