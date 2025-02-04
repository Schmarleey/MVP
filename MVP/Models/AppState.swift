//
//  AppState.swift
//  MVP
//
//  Created by Marlon Becker on 03.02.25.
//

// Models/AppState.swift
import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }
    @Published var isOnboarded: Bool = false {
        didSet {
            UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded")
        }
    }
    @Published var userId: String? = nil {
        didSet {
            UserDefaults.standard.set(userId, forKey: "userId")
        }
    }
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.userId = UserDefaults.standard.string(forKey: "userId")
    }
}
