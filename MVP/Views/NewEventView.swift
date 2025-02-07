// Views/NewEventView.swift
import SwiftUI

struct NewEventView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var eventDate: Date = Date()
    @State private var price: String = ""
    @State private var ticketInfo: String = ""
    
    // Optionales Eventbild
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Informationen")) {
                    TextField("Titel", text: $title)
                    TextField("Beschreibung", text: $description)
                    TextField("Ort", text: $location)
                    DatePicker("Datum und Uhrzeit", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Preis", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Ticket Info (optional)", text: $ticketInfo)
                }
                
                Section(header: Text("Event Bild")) {
                    HStack {
                        Spacer()
                        Button(action: { showingImagePicker = true }) {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                }
                
                Section {
                    Button(action: { createEvent() }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Event erstellen")
                        }
                    }
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Neues Event")
            .navigationBarItems(leading: Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
        }
    }
    
    func createEvent() {
        guard let userId = appState.userId else {
            errorMessage = "Keine User-ID gefunden."
            isLoading = false
            return
        }
        isLoading = true
        
        if let image = selectedImage {
            SupabaseService.shared.uploadEventImage(image: image) { result in
                switch result {
                case .success(let imageUrl):
                    // Rufe sendEvent mit imageUrl und userId auf
                    sendEvent(with: imageUrl, userId: userId)
                case .failure(let error):
                    DispatchQueue.main.async {
                        errorMessage = "Fehler beim Bildupload: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        } else {
            // Kein Bild ausgewählt: Übergib nil explizit als Profile
            sendEvent(with: nil, userId: userId)
        }
    }
    
    func sendEvent(with imageUrl: String?, userId: String) {
        // Versuche, den Preis in Double umzuwandeln (falls fehlerhaft, wird 0.0 genutzt)
        let eventPrice = Double(price) ?? 0.0
        
        let event = Event(
            id: UUID().uuidString,
            creatorId: userId,
            title: title,
            description: description,
            location: location.isEmpty ? nil : location,
            eventDate: eventDate,
            price: eventPrice,
            ticketInfo: ticketInfo.isEmpty ? nil : ticketInfo,
            eventImage: imageUrl,
            createdAt: Date()
        )
        
        EventService.shared.createEvent(event: event) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView().environmentObject(AppState())
    }
}
