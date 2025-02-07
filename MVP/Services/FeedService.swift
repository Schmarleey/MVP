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
    
    // Lädt alle SocialPosts aus der View
    func fetchSocialPosts(completion: @escaping (Result<[SocialPost], Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("social_posts")
                    .select("*")
                    .order("createdAt", ascending: false)
                    .execute()
                let data = response.data
                if data.isEmpty {
                    completion(.success([]))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let posts = try decoder.decode([SocialPost].self, from: data)
                    completion(.success(posts))
                }
            } catch {
                print("FeedService: Fehler beim Laden der SocialPosts: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // Erstellt einen neuen Post in der Tabelle "posts"
    func createPost(post: Post, completion: @escaping (Result<Post, Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("posts")
                    .insert(post)
                    .select("*")
                    .execute()
                let data = response.data
                if data.isEmpty {
                    let error = NSError(domain: "FeedService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let newPosts = try decoder.decode([Post].self, from: data)
                    if let newPost = newPosts.first {
                        completion(.success(newPost))
                    } else {
                        let error = NSError(domain: "FeedService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not created"])
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
