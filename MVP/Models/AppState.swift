// Models/AppState.swift
import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false {
        didSet { UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn") }
    }
    @Published var userId: String? = nil {
        didSet {
            UserDefaults.standard.set(userId, forKey: "userId")
            // Wenn sich die UserID ändert, laden wir den isOnboarded-Status für diesen Account:
            if let uid = userId {
                self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded-\(uid)")
            } else {
                self.isOnboarded = false
            }
        }
    }
    @Published var currentUsername: String? = nil {
        didSet { UserDefaults.standard.set(currentUsername, forKey: "currentUsername") }
    }
    @Published var isOnboarded: Bool = false {
        didSet {
            if let uid = userId {
                UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded-\(uid)")
            }
        }
    }
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.userId = UserDefaults.standard.string(forKey: "userId")
        self.currentUsername = UserDefaults.standard.string(forKey: "currentUsername")
        if let uid = userId {
            self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded-\(uid)")
        } else {
            self.isOnboarded = false
        }
    }
}
