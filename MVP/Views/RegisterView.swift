// Views/RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var infoMessage = ""
    @State private var isLoading = false
    @State private var showConfirmationAlert = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Registrierung")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Passwort", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            if !infoMessage.isEmpty {
                Text(infoMessage)
                    .foregroundColor(.blue)
            }
            
            Button(action: { register() }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Registrieren")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
        .alert("Registrierung erfolgreich", isPresented: $showConfirmationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Bitte bestätige deine E-Mail, um fortzufahren.")
        }
    }
    
    func register() {
        guard !email.isEmpty, !password.isEmpty else {
            infoMessage = "Bitte E-Mail und Passwort eingeben."
            return
        }
        isLoading = true
        // Hier kannst du einen Redirect URL (z. B. einen benutzerdefinierten Deep-Link) angeben.
        let redirectURL = URL(string: "myapp://onboarding")
        SupabaseService.shared.register(email: email, password: password, redirectURL: redirectURL) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    // Falls doch eine Session zurückgegeben wird, (unüblich) informieren wir den Nutzer.
                    infoMessage = "Registrierung erfolgreich. Bitte melde dich an."
                case .failure(let error):
                    // Wenn der Fehler darauf hinweist, dass keine Session erhalten wurde, interpretieren wir dies als Erfolg.
                    if error.localizedDescription.contains("Keine Session erhalten") {
                        infoMessage = "Registrierung erfolgreich. Bitte bestätige deine E-Mail."
                        showConfirmationAlert = true
                    } else {
                        infoMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView().environmentObject(AppState())
        }
    }
}
