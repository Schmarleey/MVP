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
    
    // Generische Funktion zum Hochladen eines Bildes in einen angegebenen Bucket
    func uploadImage(image: UIImage, bucket: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            let error = NSError(domain: "Supabase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bildkonvertierung fehlgeschlagen"])
            completion(.failure(error))
            return
        }
        let fileName = "\(UUID().uuidString).jpg"
        Task {
            do {
                _ = try await client.storage.from(bucket).upload(fileName, data: imageData)
                // Konstruieren der öffentlichen URL manuell
                let publicUrl = "\(Config.supabaseURL)/storage/v1/object/public/\(bucket)/\(fileName)"
                completion(.success(publicUrl))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Convenience-Funktion: Profilbild hochladen (in "profile-images")
    func uploadProfileImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        uploadImage(image: image, bucket: "profile-images", completion: completion)
    }
    
    // Convenience-Funktion: Postbild hochladen (in "post-images")
    func uploadPostImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        uploadImage(image: image, bucket: "post-images", completion: completion)
    }
    
    // Convenience-Funktion: Eventbild hochladen (in "event-images")
    func uploadEventImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        uploadImage(image: image, bucket: "event-images", completion: completion)
    }
    
    // SignOut: Meldet den Nutzer ab
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await client.auth.signOut()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
