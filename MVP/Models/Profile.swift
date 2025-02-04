// Models/Profile.swift
import Foundation

struct Profile: Identifiable, Codable {
    let id: String
    let email: String
    let username: String
    let name: String?
    let profileImage: String?
    let interests: [String]?
    let role: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, email, username, name, interests, role
        case profileImage = "profile_image"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        // Manuelles Dekodieren von profile_image:
        if container.contains(.profileImage) {
            profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        } else {
            profileImage = nil
        }
        interests = try container.decodeIfPresent([String].self, forKey: .interests)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
}
