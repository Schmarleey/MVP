// Models/Tab.swift
import SwiftUI

enum Tab: Int, CaseIterable, Identifiable {
    case feed, events, profile
    var id: Int { self.rawValue }
    
    var defaultIconName: String {
        switch self {
        case .feed: return "list.bullet"
        case .events: return "calendar"
        case .profile: return "person.circle"
        }
    }
}
