import Foundation

struct ProfileUpdateData: Encodable {
    let name: String
    let username: String
    let profile_image: String
    let interests: [String]
}
