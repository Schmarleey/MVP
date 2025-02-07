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
    
    // Initialer Source Type (z.B. .camera)
    var initialSourceType: UIImagePickerController.SourceType = .camera
    
    // Falls der initialSourceType nicht verfügbar ist, wird .photoLibrary verwendet.
    var effectiveSourceType: UIImagePickerController.SourceType {
        return UIImagePickerController.isSourceTypeAvailable(initialSourceType) ? initialSourceType : .photoLibrary
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Bildvorschau (falls ausgewählt)
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipped()
                        .clipShape(Circle())
                        .shadow(radius: 4)
                } else {
                    Image(systemName: "camera.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                
                // Button zum Öffnen des ImagePickers
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
                
                // Posten-Button
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
                // Falls noch kein Bild ausgewählt wurde, ImagePicker automatisch öffnen.
                if selectedImage == nil {
                    showingImagePicker = true
                }
            }
        }
    }
    
    func createPost() {
        guard let userId = appState.userId else {
            errorMessage = "Keine User-ID gefunden."
            return
        }
        isLoading = true
        if let image = selectedImage {
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
            sendPost(with: nil, userId: userId)
        }
    }
    
    func sendPost(with imageUrl: String?, userId: String) {
        let dummyId = UUID().uuidString
        // Hier wird der Post mit exakt 6 Parametern erstellt:
        let post = Post(
            id: dummyId,
            userId: userId,
            mediaUrl: imageUrl,
            message: message,
            createdAt: Date(),
            profile: nil  // Wenn kein Profil übergeben werden soll, explizit nil vom Typ Profile?
        )
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
