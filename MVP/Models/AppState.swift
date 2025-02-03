//
//  AppState.swift
//  MVP
//
//  Created by Marlon Becker on 03.02.25.
//

// Models/AppState.swift
import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isOnboarded: Bool = false
    @Published var userId: String? = nil  // Neue Eigenschaft für die User-ID
}
