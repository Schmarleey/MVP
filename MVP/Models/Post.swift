// Models/Post.swift
import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    let mediaUrl: String?
    let message: String?
    let createdAt: Date?
    /// Die verbundenen Profil-Daten – der JSON-Key "profiles" wird in _profile gemappt
    private let _profile: Profile?
    
    // Computed Properties für den Zugriff in den Views
    var profile: Profile? { _profile }
    var username: String? { _profile?.username }
    var profileImage: String? { _profile?.profileImage }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case mediaUrl = "media_url"
        case message
        case createdAt = "created_at"
        case profiles
    }
    
    // Memberwise initializer – genau 6 Parameter
    init(id: String,
         userId: String,
         mediaUrl: String? = nil,
         message: String? = nil,
         createdAt: Date? = nil,
         profile: Profile? = nil) {
        self.id = id
        self.userId = userId
        self.mediaUrl = mediaUrl
        self.message = message
        self.createdAt = createdAt
        self._profile = profile
    }
    
    // Custom Decodable-Initializer: Versuche, "profiles" als einzelnes Profile zu dekodieren;
    // falls das fehlschlägt, als Array und nehme das erste Element.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        mediaUrl = try container.decodeIfPresent(String.self, forKey: .mediaUrl)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        if let singleProfile = try? container.decode(Profile.self, forKey: .profiles) {
            _profile = singleProfile
        } else if let profilesArray = try? container.decode([Profile].self, forKey: .profiles),
                  let firstProfile = profilesArray.first {
            _profile = firstProfile
        } else {
            _profile = nil
        }
    }
    
    // Custom Encodable-Implementierung – kodiert nur die Post-Felder, nicht den Join
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(mediaUrl, forKey: .mediaUrl)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        // Den Schlüssel "profiles" kodieren wir nicht
    }
}
