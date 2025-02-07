// Models/SocialPost.swift
import Foundation

struct SocialPost: Identifiable, Codable {
    let id: String
    let userId: String
    let mediaUrl: String?
    let message: String?
    let createdAt: Date?
    let username: String?
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case mediaUrl
        case message
        case createdAt
        case username
        case profileImage
    }
}
