import SwiftUI

struct EventFeedView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        // Ermittele, ob ein Monatsmarker angezeigt werden soll:
                        let showMarker = shouldShowMonthMarker(at: index)
                        let monthText = showMarker ? formattedMonth(for: event.eventDate) : nil
                        
                        TimelineEventRow(event: event, showMonthMarker: showMarker, monthText: monthText)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarHidden(true)
                .onAppear(perform: loadEvents)
                .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                    Alert(title: Text("Fehler"),
                          message: Text(errorMessage),
                          dismissButton: .default(Text("OK")))
                }
                
                // Overlay: Floating Search Bar in der oberen rechten Ecke
                VStack {
                    HStack {
                        Spacer()
                        FloatingSearchBar(searchText: $searchText, isSearchActive: $isSearchActive)
                            .padding(.top, 10)
                            .padding(.trailing, 20)
                    }
                    Spacer()
                }
                
                // Overlay: Floating Create Button (für Events) – links, etwas oberhalb der Tabbar
                VStack {
                    Spacer()
                    HStack {
                        TintedGlassButton(systemImage: "plus.circle.fill")
                            .onTapGesture {
                                appState.showNewEvent = true
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 80)
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $appState.showNewEvent) {
            NewEventView().environmentObject(appState)
        }
    }
    
    // Filterung der Events anhand des Suchtextes (falls aktiv)
    var filteredEvents: [Event] {
        if searchText.isEmpty {
            return events
        } else {
            return events.filter { event in
                event.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func loadEvents() {
        isLoading = true
        EventService.shared.fetchEvents { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedEvents):
                    // Sortiere chronologisch (älteste oben)
                    self.events = fetchedEvents.sorted { ($0.eventDate ?? Date.distantPast) < ($1.eventDate ?? Date.distantPast) }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Hilfsfunktion: Bestimmt, ob an der aktuellen Position ein Monatsmarker angezeigt werden soll
    func shouldShowMonthMarker(at index: Int) -> Bool {
        guard index < events.count else { return false }
        let calendar = Calendar.current
        let currentEventDate = events[index].eventDate ?? Date.distantPast
        if index == 0 {
            return true  // Erster Eintrag: Marker anzeigen
        } else {
            let previousEventDate = events[index - 1].eventDate ?? Date.distantPast
            // Marker anzeigen, wenn sich der Monat ändert:
            return !calendar.isDate(currentEventDate, equalTo: previousEventDate, toGranularity: .month)
        }
    }
    
    // Hilfsfunktion: Formatiert das Datum in "Monat Jahr" (z. B. "März 2025")
    func formattedMonth(for date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
}

struct EventFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EventFeedView().environmentObject(AppState())
    }
}
