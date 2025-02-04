//
//  EventFeedView.swift
//  MVP
//
//  Created by Marlon Becker on 04.02.25.
//

// Views/EventFeedView.swift
import SwiftUI

struct EventFeedView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.headline)
                        if let description = event.description {
                            Text(description)
                                .font(.body)
                        }
                        if let location = event.location {
                            Text(location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        if let date = event.eventDate {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Events")
            .onAppear { loadEvents() }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { !errorMessage.isEmpty },
                set: { _ in errorMessage = "" }
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func loadEvents() {
        isLoading = true
        EventService.shared.fetchEvents { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let events):
                    self.events = events
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct EventFeedView_Previews: PreviewProvider {
    static var previews: some View {
        EventFeedView()
    }
}
