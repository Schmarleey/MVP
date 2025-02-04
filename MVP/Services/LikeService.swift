// Services/LikesService.swift
import Foundation
import Supabase

class LikesService {
    static let shared = LikesService()
    private var client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseApiKey
        )
    }
    
    // Für Posts
    func likePost(postId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let likeData: [String: String] = [
                    "post_id": postId,
                    "user_id": userId
                ]
                _ = try await client.from("likes").insert(likeData).execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchPostLikes(postId: String, completion: @escaping (Result<Int, Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("likes")
                    .select("id", count: .exact)
                    .eq("post_id", value: postId)
                    .execute()
                completion(.success(response.count ?? 0))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Für Kommentare
    func likeComment(commentId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let data: [String: String] = [
                    "comment_id": commentId,
                    "user_id": userId
                ]
                _ = try await client.from("comment_likes").insert(data).execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchCommentLikes(commentId: String, completion: @escaping (Result<Int, Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("comment_likes")
                    .select("id", count: .exact)
                    .eq("comment_id", value: commentId)
                    .execute()
                completion(.success(response.count ?? 0))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
