// Views/NewPostView.swift
import SwiftUI

struct NewPostView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var message = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    // Initialer Source Type (zum Beispiel .camera)
    var initialSourceType: UIImagePickerController.SourceType = .camera
    
    // Computed Property: Falls der initialSourceType (z. B. .camera) nicht verfügbar ist, wird .photoLibrary zurückgegeben.
    var effectiveSourceType: UIImagePickerController.SourceType {
        return UIImagePickerController.isSourceTypeAvailable(initialSourceType) ? initialSourceType : .photoLibrary
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Bildvorschau (falls ein Bild ausgewählt wurde)
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                } else {
                    // Platzhalter – falls kein Bild ausgewählt
                    Image(systemName: "camera.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                
                // Button, um den ImagePicker manuell zu öffnen, falls nötig
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text(selectedImage == nil ? "Foto aufnehmen / auswählen" : "Foto ändern")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Textfeld für die Nachricht
                TextField("Nachricht...", text: $message)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Posten-Button ganz unten
                Button(action: {
                    createPost()
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Posten")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 16)
            }
            .padding()
            .navigationTitle("Neuer Beitrag")
            .navigationBarItems(leading: Button("Abbrechen") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: effectiveSourceType)
            }
            .onAppear {
                // Wenn noch kein Bild ausgewählt wurde, den ImagePicker automatisch öffnen.
                if selectedImage == nil {
                    showingImagePicker = true
                }
            }
        }
    }
    
    func createPost() {
        // Sicherstellen, dass eine User-ID vorliegt
        guard let userId = appState.userId else {
            errorMessage = "Keine User-ID gefunden."
            return
        }
        
        isLoading = true
        if let image = selectedImage {
            // Bild hochladen und dann Post erstellen
            SupabaseService.shared.uploadPostImage(image: image) { result in
                switch result {
                case .success(let imageUrl):
                    sendPost(with: imageUrl, userId: userId)
                case .failure(let error):
                    DispatchQueue.main.async {
                        errorMessage = "Fehler beim Bildupload: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        } else {
            // Kein Bild ausgewählt – Post ohne Bild erstellen
            sendPost(with: nil, userId: userId)
        }
    }
    
    func sendPost(with imageUrl: String?, userId: String) {
        // Dummy ID; der Server ersetzt sie normalerweise.
        let dummyId = UUID().uuidString
        // Hier wird auch der Parameter "profileImage" ergänzt (derzeit nil, da wir das Profilbild separat verwalten)
        let post = Post(id: dummyId, userId: userId, mediaUrl: imageUrl, message: message, createdAt: Date(), profileImage: nil)
        FeedService.shared.createPost(post: post) { result in
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

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(initialSourceType: .camera)
            .environmentObject(AppState())
    }
}
