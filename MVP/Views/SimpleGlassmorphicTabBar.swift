import SwiftUI

struct SimpleGlassmorphicTabBar: View {
    @Binding var selectedTab: Tab
    @Binding var showCreateInTabBar: Bool
    var namespace: Namespace.ID
    @EnvironmentObject var appState: AppState

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabCount = CGFloat(Tab.allCases.count)
            let tabWidth = totalWidth / tabCount
            // Compute the center x of the active tab
            let indicatorX = (CGFloat(selectedTab.rawValue) + 0.5) * tabWidth
            
            ZStack {
                // Background capsule for the tab bar
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                
                // The selection indicator (black circle) drawn behind the icons
                if showCreateInTabBar {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        // Position the circle in the center of the active tab
                        .position(x: indicatorX, y: geo.size.height / 2)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: selectedTab)
                }
                
                // The tab buttons (icons) on top
                HStack(spacing: 0) {
                    ForEach(Tab.allCases) { tab in
                        Button(action: {
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                                if tab == .events && selectedTab == tab && showCreateInTabBar {
                                    appState.showNewEvent = true
                                } else if tab == .feed && selectedTab == tab && showCreateInTabBar {
                                    appState.showNewPost = true 
                                } else {
                                    selectedTab = tab
                                }
                            }
                        }) {
                            Image(systemName: iconName(for: tab))
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == tab ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .frame(width: totalWidth, height: geo.size.height)
                .zIndex(1)
            }
        }
        .frame(height: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
    func iconName(for tab: Tab) -> String {
        if selectedTab == tab {
            switch tab {
            case .feed: return "camera.fill"
            case .events: return "plus"
            case .profile: return "person.circle.fill"
            }
        }
        return tab.defaultIconName
    }
}

struct SimpleGlassmorphicTabBar_Previews: PreviewProvider {
    static var previews: some View {
        SimpleGlassmorphicTabBar(selectedTab: .constant(.feed),
                                 showCreateInTabBar: .constant(true),
                                 namespace: Namespace().wrappedValue)
            .environmentObject(AppState())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
