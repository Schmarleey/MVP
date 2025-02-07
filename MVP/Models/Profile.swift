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
    
    // Diesen memberwise Initializer fügen wir hinzu, damit wir Profile manuell erstellen können.
    init(id: String,
         email: String,
         username: String,
         name: String?,
         profileImage: String?,
         interests: [String]?,
         role: String?,
         createdAt: Date?) {
        self.id = id
        self.email = email
        self.username = username
        self.name = name
        self.profileImage = profileImage
        self.interests = interests
        self.role = role
        self.createdAt = createdAt
    }
    
    // Der Decodable-Initializer (kann so bleiben)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        interests = try container.decodeIfPresent([String].self, forKey: .interests)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
}
