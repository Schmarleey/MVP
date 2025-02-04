// Views/RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
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

            Button(action: {
                register()
            }) {
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
            Button("OK", role: .cancel) {
                // Schließt die RegisterView und kehrt zur LoginView zurück.
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Bitte bestätige deine E-Mail, um fortzufahren.")
        }
    }

    func register() {
        guard !email.isEmpty, !password.isEmpty else {
            infoMessage = "Bitte E-Mail und Passwort eingeben."
            return
        }

        infoMessage = ""
        isLoading = true

        SupabaseService.shared.register(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let session):
                    print("Registrierung erfolgreich, Session: \(session)")
                    // Falls ausnahmsweise eine Session zurückgegeben wird.
                    showConfirmationAlert = true
                case .failure(let error):
                    // Wenn der Fehlertext "Keine Session erhalten" enthält,
                    // interpretieren wir dies als erfolgreiche Registrierung mit E-Mail-Bestätigung.
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
        RegisterView()
    }
}
