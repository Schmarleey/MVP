import SwiftUI

struct EventFeedView: View {
    @State private var events: [Event] = []
    @State private var errorMessage: String = ""
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hexValue: "#fffdfa").ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                            if shouldShowMonthHeader(at: index) {
                                MonthHeaderView(month: formattedMonthHeader(for: event.eventDate))
                            }
                            TimelineEventRow(event: event)
                        }
                        FooterView()
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 8)
                }
                
                VStack(alignment: .trailing) {
                    FloatingSearchBar(searchText: $searchText, isSearchActive: $isSearchActive)
                        .padding(.trailing, 0) // Optional für zusätzlichen Abstand
                        .padding(.top, 0)
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear(perform: loadEvents)
            .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                Alert(title: Text("Fehler"),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $appState.showNewEvent) {
            NewEventBuilderView().environmentObject(appState)
        }
    }
    
    func shouldShowMonthHeader(at index: Int) -> Bool {
        guard index < events.count else { return false }
        let eventDate = events[index].eventDate ?? Date.distantPast
        if Calendar.current.isDate(eventDate, equalTo: Date(), toGranularity: .month) {
            return false
        }
        if index == 0 { return true }
        let previousDate = events[index - 1].eventDate ?? Date.distantPast
        return !Calendar.current.isDate(eventDate, equalTo: previousDate, toGranularity: .month)
    }
    
    func formattedMonthHeader(for date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
    
    func loadEvents() {
        EventService.shared.fetchEvents { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedEvents):
                    self.events = fetchedEvents.sorted { ($0.eventDate ?? Date.distantPast) < ($1.eventDate ?? Date.distantPast) }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct FooterView: View {
    var body: some View {
        Text("Nothing planned")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity)
            .transition(.opacity)
    }
}

struct MonthHeaderView: View {
    let month: String
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color(hexValue: "#204039"))
                .frame(width: 4)
            Text(month)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hexValue: "#f7b32b"))
                .padding(.leading, 4)
            Spacer()
        }
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 4)
    }
}

struct EventFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EventFeedView().environmentObject(AppState())
    }
}
