// Models/CommentLike.swift
import Foundation

struct CommentLike: Identifiable, Codable {
    let id: String
    let commentId: String
    let userId: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case commentId = "comment_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
