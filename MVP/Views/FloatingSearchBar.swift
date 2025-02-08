import SwiftUI

struct FloatingSearchBar: View {
    @Binding var searchText: String
    @Binding var isSearchActive: Bool
    
    var body: some View {
        HStack {
            if isSearchActive {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.primary)
                TextField("Suchen...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.primary)
                    .disableAutocorrection(true)
                Button(action: {
                    withAnimation {
                        searchText = ""
                        isSearchActive = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.primary)
                }
            } else {
                Button(action: {
                    withAnimation {
                        isSearchActive = true
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                )
        )
        .frame(maxWidth: isSearchActive ? 390 : 50)
        .animation(.easeInOut(duration: 0.15), value: isSearchActive)
    }
}

struct FloatingSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper("") { searchText in
            StatefulPreviewWrapper(false) { isActive in
                FloatingSearchBar(searchText: searchText, isSearchActive: isActive)
                    .padding()
            }
        }
    }
}

// Helper for stateful preview:
struct StatefulPreviewWrapper<Value: Equatable, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
