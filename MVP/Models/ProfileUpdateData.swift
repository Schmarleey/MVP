//
//  ProfileUpdateData.swift
//  MVP
//
//  Created by Marlon Becker on 03.02.25.
//

import Foundation

struct ProfileUpdateData: Encodable {
    let name: String
    let username: String
    let profile_image: String
    let interests: [String]
}
