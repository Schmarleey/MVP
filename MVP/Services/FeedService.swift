// Services/FeedService.swift
import Foundation
import Supabase

class FeedService {
    static let shared = FeedService()
    private var client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseApiKey
        )
    }
    
    // Lädt alle Posts für den Social Feed
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("posts").select("*").execute()
                let data = response.data
                if data.isEmpty {
                    let error = NSError(domain: "FeedService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let posts = try decoder.decode([Post].self, from: data)
                    completion(.success(posts))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Erstellt einen neuen Post
    func createPost(post: Post, completion: @escaping (Result<Post, Error>) -> Void) {
        Task {
            do {
                // Statt das Post-Objekt zu codieren, übergeben wir es direkt.
                let response = try await client.from("posts").insert(post).select("*").execute()
                let data = response.data
                if data.isEmpty {
                    let error = NSError(domain: "FeedService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    do {
                        let newPosts = try decoder.decode([Post].self, from: data)
                        if let newPost = newPosts.first {
                            completion(.success(newPost))
                        } else {
                            let error = NSError(domain: "FeedService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not created"])
                            completion(.failure(error))
                        }
                    } catch {
                        do {
                            let newPost = try decoder.decode(Post.self, from: data)
                            completion(.success(newPost))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
