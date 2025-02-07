// Models/Event.swift
import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let creatorId: String?
    let title: String
    let description: String?
    let location: String?
    let eventDate: Date?
    let price: Double?
    let ticketInfo: String?
    let eventImage: String?    // Neu: URL zum Eventbild
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId = "creator_id"
        case title
        case description
        case location
        case eventDate = "event_date"
        case price
        case ticketInfo = "ticket_info"
        case eventImage = "event_image"
        case createdAt = "created_at"
    }
}
