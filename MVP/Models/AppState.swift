import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false {
        didSet { UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn") }
    }
    @Published var userId: String? = nil {
        didSet {
            UserDefaults.standard.set(userId, forKey: "userId")
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
    @Published var showNewPost: Bool = false
    @Published var showNewEvent: Bool = false
    @Published var selectedEvent: Event? = nil
    
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
