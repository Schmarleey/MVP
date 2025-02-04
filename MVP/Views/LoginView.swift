// Views/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Login")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: { login() }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            NavigationLink("Noch kein Konto? Jetzt registrieren", destination: RegisterView().environmentObject(appState))
            
            Spacer()
        }
        .padding()
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte Email und Passwort eingeben."
            return
        }
        isLoading = true
        SupabaseService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let session):
                    print("Erfolgreich eingeloggt: \(session)")
                    appState.isLoggedIn = true
                    appState.userId = session.user.id.uuidString
                    appState.currentUsername = "Du"
                    appState.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView().environmentObject(AppState())
        }
    }
}
