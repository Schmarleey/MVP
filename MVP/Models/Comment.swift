// Models/Comment.swift
import Foundation

struct Comment: Identifiable, Codable {
    let id: String
    let postId: String
    let userId: String
    let comment: String
    let createdAt: Date?
    let parentCommentId: String?  // Für verschachtelte Antworten

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case comment
        case createdAt = "created_at"
        case parentCommentId = "parent_comment_id"
    }
}
