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
    
    // fetchProfile: Lädt das Profil des Nutzers anhand der userId
    func fetchProfile(userId: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("profiles")
                    .select("*")
                    .eq("id", value: userId)
                    .single()
                    .execute()
                let data = response.data
                // Debug: Ausgabe des JSON-Response als String
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                } else {
                    print("Response data konnte nicht als String decodiert werden")
                }
                if data.isEmpty {
                    let error = NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten"])
                    completion(.failure(error))
                } else {
                    let decoder = JSONDecoder()
                    
                    // Erstelle einen DateFormatter, der Fractional Seconds unterstützt:
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    // Format: "2025-02-03T17:12:22.103886+00:00"
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
                    
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    // Wir nutzen hier nicht die automatische Schlüsselkonvertierung,
                    // da unser Model in den CodingKeys bereits explizit definiert ist.
                    let profile = try decoder.decode(Profile.self, from: data)
                    print("Decodiertes Profil: \(profile)")
                    completion(.success(profile))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
