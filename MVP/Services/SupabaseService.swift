// Services/SupabaseService.swift
import Foundation
import Supabase
import UIKit

class SupabaseService {
    static let shared = SupabaseService()
    
    private var client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseApiKey
        )
    }
    
    // Login: Gibt ein Session-Objekt zurück, falls erfolgreich
    func login(email: String, password: String, completion: @escaping (Result<Session, Error>) -> Void) {
        Task {
            do {
                let session: Session = try await client.auth.signIn(email: email, password: password)
                completion(.success(session))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Registrierung: Bei aktivierter E-Mail-Bestätigung wird in der Regel keine Session zurückgegeben.
    func register(email: String, password: String, redirectURL: URL? = nil, completion: @escaping (Result<Session, Error>) -> Void) {
        Task {
            do {
                let authResponse = try await client.auth.signUp(email: email, password: password, redirectTo: redirectURL)
                if case let AuthResponse.session(session) = authResponse {
                    completion(.success(session))
                } else {
                    let error = NSError(domain: "Supabase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Keine Session erhalten"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // updateProfile: Aktualisiert den Profil-Datensatz in der "profiles"-Tabelle
    func updateProfile(userId: String, name: String, username: String, profileImage: String, interests: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let updateData = ProfileUpdateData(name: name, username: username, profile_image: profileImage, interests: interests)
                _ = try await client.from("profiles").update(updateData).eq("id", value: userId).execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // uploadProfileImage: Wandelt das UIImage in JPEG-Daten um, lädt es in den Bucket "profile-images" hoch und liefert die öffentliche URL zurück.
    func uploadProfileImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            let error = NSError(domain: "Supabase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bildkonvertierung fehlgeschlagen"])
            completion(.failure(error))
            return
        }
        let fileName = "\(UUID().uuidString).jpg"
        Task {
            do {
                // Lade das Bild in den Bucket "profile-images" hoch.
                _ = try await client.storage.from("profile-images").upload(fileName, data: imageData)
                // Konstruieren der öffentlichen URL manuell:
                let publicUrl = "\(Config.supabaseURL)/storage/v1/object/public/profile-images/\(fileName)"
                completion(.success(publicUrl))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
