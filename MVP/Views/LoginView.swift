// Views/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)  // Für AutoFill
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)       // Für AutoFill
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
                
                NavigationLink(destination: RegisterView().environmentObject(appState)) {
                    Text("Noch kein Konto? Jetzt registrieren")
                        .foregroundColor(.blue)
                        .underline()
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
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
                    appState.isLoggedIn = true
                    appState.userId = session.user.id.uuidString
                    appState.currentUsername = session.user.email  // Oder den tatsächlichen Username, wenn vorhanden
                    // Wichtig: Das Onboarding wird _nicht_ zurückgesetzt, wenn es bereits abgeschlossen wurde.
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AppState())
    }
}
