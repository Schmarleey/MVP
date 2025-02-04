// Models/Post.swift
import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    let mediaUrl: String?
    let message: String?
    let createdAt: Date?
    let profileImage: String?
    let username: String?  // tatsächlicher Username des Posters

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mediaUrl = "media_url"
        case message
        case createdAt = "created_at"
        case profileImage = "profile_image"
        case profiles
    }
    
    // Hilfsstruktur zum Dekodieren des verschachtelten Profiles-Arrays
    struct Profile: Codable {
        let username: String?
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        mediaUrl = try container.decodeIfPresent(String.self, forKey: .mediaUrl)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        
        if let profilesArray = try? container.decode([Profile].self, forKey: .profiles),
           let firstProfile = profilesArray.first {
            username = firstProfile.username
        } else {
            username = nil
        }
    }
    
    // Encode-Funktion – wir codieren alle gespeicherten Eigenschaften, aber nicht "profiles"
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(mediaUrl, forKey: .mediaUrl)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(profileImage, forKey: .profileImage)
    }
    
    // Memberwise Initializer für Previews und manuelle Instanziierung
    init(id: String,
         userId: String,
         mediaUrl: String? = nil,
         message: String? = nil,
         createdAt: Date? = nil,
         profileImage: String? = nil,
         username: String? = nil) {
        self.id = id
        self.userId = userId
        self.mediaUrl = mediaUrl
        self.message = message
        self.createdAt = createdAt
        self.profileImage = profileImage
        self.username = username
    }
}
