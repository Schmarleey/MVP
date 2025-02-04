// Models/AppState.swift
import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false {
        didSet { UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn") }
    }
    @Published var isOnboarded: Bool = false {
        didSet { UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded") }
    }
    @Published var userId: String? = nil {
        didSet { UserDefaults.standard.set(userId, forKey: "userId") }
    }
    @Published var currentUsername: String? = nil {
        didSet { UserDefaults.standard.set(currentUsername, forKey: "currentUsername") }
    }
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.userId = UserDefaults.standard.string(forKey: "userId")
        self.currentUsername = UserDefaults.standard.string(forKey: "currentUsername")
    }
}
