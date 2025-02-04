//
//  Untitled.swift
//  MVP
//
//  Created by Marlon Becker on 04.02.25.
//

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
        case createdAt = "created_at"
    }
}
