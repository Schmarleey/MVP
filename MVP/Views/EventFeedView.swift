import SwiftUI

struct EventFeedView: View {
    @State private var events: [Event] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(events) { event in
                        VStack(alignment: .leading, spacing: 8) {
                            if let imageUrl = event.eventImage, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().frame(height: 200)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                            .clipped()
                                    case .failure(_):
                                        Color.gray.frame(height: 200)
                                    @unknown default:
                                        Color.gray.frame(height: 200)
                                    }
                                }
                                .cornerRadius(8)
                            } else {
                                Color.gray
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .cornerRadius(8)
                            }
                            
                            Text(event.title)
                                .font(.headline)
                            if let description = event.description {
                                Text(description)
                                    .font(.body)
                                    .lineLimit(2)
                            }
                            if let location = event.location {
                                Text(location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            if let eventDate = event.eventDate {
                                Text(eventDate, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Events")
                .onAppear(perform: loadEvents)
                .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                    Alert(title: Text("Error"),
                          message: Text(errorMessage),
                          dismissButton: .default(Text("OK")))
                }
                
                // Overlay: Floating Create-Button (links oben) in der EventFeedView
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                appState.showNewEvent = true
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }) {
                                TintedGlassButton(systemImage: "plus.circle.fill")
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, 130)
                            Spacer()
                        }
                        .frame(width: geometry.size.width, alignment: .bottomLeading)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $appState.showNewEvent) {
            NewEventView().environmentObject(appState)
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
        EventFeedView().environmentObject(AppState())
    }
}
