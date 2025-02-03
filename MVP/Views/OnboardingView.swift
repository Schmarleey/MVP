// Views/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var username = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var selectedInterests: [String] = []
    @State private var infoMessage = ""
    @State private var isLoading = false

    // Vorgegebene Interessen – passend zum Kontext von Erlebnissen/Events.
    let interestOptions = ["Abenteuer", "Kulinarik", "Kultur", "Sport", "Musik", "Party", "Outdoor", "Reisen", "Entspannung", "Workshops", "Kreativ"]

    // Greife auf die User-ID aus dem AppState zu.
    var userId: String? { appState.userId }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profilbild Upload Feld (Apple-typisch) – zentriert
                HStack {
                    Spacer()
                    Button(action: { showingImagePicker = true }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                
                // Textfelder für Name und Username
                VStack(spacing: 16) {
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                // Interessen-Auswahl als Tag-Cloud
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wähle deine Interessen:")
                        .font(.headline)
                    TagCloudView(tags: interestOptions, spacing: 8, onTap: { interest in
                        if selectedInterests.contains(interest) {
                            selectedInterests.removeAll { $0 == interest }
                        } else {
                            selectedInterests.append(interest)
                        }
                    }, isSelected: { interest in
                        selectedInterests.contains(interest)
                    })
                }
                
                // Platzhalter für Info-Meldung
                if !infoMessage.isEmpty {
                    Text(infoMessage)
                        .foregroundColor(.blue)
                }
                
                // Spacer, um den Inhalt nach oben zu drücken
                Spacer(minLength: 40)
                
                // Speichern-Button – fix ganz unten
                Button(action: { updateProfile() }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Speichern")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical,90)
            }
            .frame(minHeight: UIScreen.main.bounds.height - 40)
            .padding()
        }
        .sheet(isPresented: $showingImagePicker) { ImagePicker(selectedImage: $selectedImage) }
    }
    
    func updateProfile() {
        // Pflichtfelder validieren
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            infoMessage = "Name und Benutzername müssen ausgefüllt sein!"
            return
        }
        // Sicherstellen, dass eine User-ID vorhanden ist:
        guard let actualUserId = userId else {
            infoMessage = "Fehler: Keine User-ID gefunden."
            return
        }
        
        isLoading = true
        if let image = selectedImage {
            // Upload des ausgewählten Bildes in Supabase Storage
            SupabaseService.shared.uploadProfileImage(image: image) { result in
                switch result {
                case .success(let imageUrl):
                    updateProfileWithImageUrl(imageUrl, actualUserId: actualUserId)
                case .failure(let error):
                    DispatchQueue.main.async {
                        infoMessage = "Fehler beim Hochladen des Bildes: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        } else {
            // Kein Bild ausgewählt – Standardbild verwenden
            updateProfileWithImageUrl("https://example.com/default-profile.jpg", actualUserId: actualUserId)
        }
    }
    
    func updateProfileWithImageUrl(_ imageUrl: String, actualUserId: String) {
        SupabaseService.shared.updateProfile(userId: actualUserId,
                                             name: name,
                                             username: username,
                                             profileImage: imageUrl,
                                             interests: selectedInterests) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success():
                    infoMessage = "Profil aktualisiert!"
                    appState.isOnboarded = true
                case .failure(let error):
                    infoMessage = error.localizedDescription
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView().environmentObject(AppState())
        }
    }
}
