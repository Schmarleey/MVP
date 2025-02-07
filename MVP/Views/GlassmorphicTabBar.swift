import SwiftUI

enum Tab: Int, CaseIterable {
    case feed, events, profile
    
    var iconName: String {
        switch self {
        case .feed: return "list.bullet"
        case .events: return "calendar"
        case .profile: return "person.circle"
        }
    }
}

struct TabItemPreferenceKey: PreferenceKey {
    static var defaultValue: [Tab: CGRect] = [:]
    static func reduce(value: inout [Tab : CGRect], nextValue: () -> [Tab : CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct GlassmorphicTabBar: View {
    @Binding var selectedTab: Tab
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                        selectedTab = tab
                        feedbackGenerator.impactOccurred()
                    }
                }) {
                    if selectedTab == tab {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                            Image(systemName: tab.iconName)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    } else {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        // Feste Höhe für die Tabbar: so nimmt sie nur den gewünschten Bereich ein
        .frame(height: 70)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct GlassmorphicTabBar_Previews: PreviewProvider {
    static var previews: some View {
        GlassmorphicTabBar(selectedTab: .constant(.feed))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
