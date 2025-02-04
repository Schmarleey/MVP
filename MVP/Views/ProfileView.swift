// Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var remoteProfileImageUrl: String? = nil
    @State private var showingImagePicker: Bool = false
    @State private var isLoading: Bool = false
    @State private var infoMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profilbild")) {
                    HStack {
                        Spacer()
                        Button(action: { showingImagePicker = true }) {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let urlString = remoteProfileImageUrl,
                                      let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable()
                                            .scaledToFill()
                                    } else if phase.error != nil {
                                        Image(systemName: "person.crop.circle.badge.exclam")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.gray)
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .id(remoteProfileImageUrl)
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                }
                
                Section(header: Text("Informationen")) {
                    TextField("Name", text: $name)
                    TextField("Username", text: $username)
                }
                
                Section {
                    Button(action: { updateProfile() }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Profil aktualisieren")
                        }
                    }
                }
                
                Section {
                    Button(action: { signOut() }) {
                        Text("Abmelden")
                            .foregroundColor(.red)
                    }
                }
                
                if !infoMessage.isEmpty {
                    Section {
                        Text(infoMessage)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $profileImage, sourceType: .photoLibrary)
            }
            .onAppear(perform: loadProfile)
        }
    }
    
    func loadProfile() {
        guard let userId = appState.userId else {
            self.infoMessage = "Keine User ID gefunden."
            return
        }
        isLoading = true
        SupabaseService.shared.fetchProfile(userId: userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.username = profile.username
                    self.name = profile.name ?? ""
                    self.remoteProfileImageUrl = profile.profileImage
                    print("Geladenes Profilbild URL: \(profile.profileImage ?? "kein Bild")")
                case .failure(let error):
                    self.infoMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateProfile() {
        guard let userId = appState.userId else {
            infoMessage = "User ID nicht gefunden."
            return
        }
        isLoading = true
        if let image = profileImage {
            SupabaseService.shared.uploadProfileImage(image: image) { result in
                switch result {
                case .success(let imageUrl):
                    performProfileUpdate(imageUrl: imageUrl, userId: userId)
                case .failure(let error):
                    DispatchQueue.main.async {
                        infoMessage = "Fehler beim Hochladen des Bildes: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        } else {
            performProfileUpdate(imageUrl: remoteProfileImageUrl ?? "https://example.com/default-profile.jpg", userId: userId)
        }
    }
    
    func performProfileUpdate(imageUrl: String, userId: String) {
        SupabaseService.shared.updateProfile(userId: userId, name: name, username: username, profileImage: imageUrl, interests: []) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success():
                    infoMessage = "Profil erfolgreich aktualisiert."
                    appState.currentUsername = username
                case .failure(let error):
                    infoMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        isLoading = true
        SupabaseService.shared.signOut { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success():
                    appState.isLoggedIn = false
                    appState.userId = nil
                    appState.currentUsername = nil
                case .failure(let error):
                    infoMessage = error.localizedDescription
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AppState())
    }
}
