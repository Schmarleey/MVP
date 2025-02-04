// Services/CommentsService.swift
import Foundation
import Supabase

class CommentsService {
    static let shared = CommentsService()
    private var client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseApiKey
        )
    }
    
    // Lädt alle Kommentare für einen bestimmten Post (nur Hauptkommentare, also ohne parent_comment_id)
    func fetchComments(postId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("comments")
                    .select("*")
                    .eq("post_id", value: postId)
                    // Statt NSNull() verwenden wir hier den String "null"
                    .filter("parent_comment_id", operator: "is", value: "null")
                    .order("created_at", ascending: true)
                    .execute()
                let data = response.data
                if data.isEmpty {
                    completion(.success([]))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let comments = try decoder.decode([Comment].self, from: data)
                    completion(.success(comments))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Lädt Antworten (Replies) zu einem Kommentar
    func fetchReplies(parentCommentId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("comments")
                    .select("*")
                    .eq("parent_comment_id", value: parentCommentId)
                    .order("created_at", ascending: true)
                    .execute()
                let data = response.data
                if data.isEmpty {
                    completion(.success([]))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let replies = try decoder.decode([Comment].self, from: data)
                    completion(.success(replies))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Erstellt einen neuen Kommentar (oder Reply, wenn parent_comment_id gesetzt ist)
    func createComment(comment: Comment, completion: @escaping (Result<Comment, Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("comments")
                    .insert(comment)
                    .select("*")
                    .execute()
                let data = response.data
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let createdComments = try decoder.decode([Comment].self, from: data)
                if let newComment = createdComments.first {
                    completion(.success(newComment))
                } else {
                    let error = NSError(domain: "CommentsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kommentar nicht erstellt"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
