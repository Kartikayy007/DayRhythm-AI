//
//  User.swift
//  DayRhythm AI
//
//  Created by kartikay on 29/10/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let createdAt: Date
    let displayName: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
        case displayName = "display_name"
        case avatarURL = "avatar_url"
    }

    init(id: String, email: String, createdAt: Date = Date(), displayName: String? = nil, avatarURL: String? = nil) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
}
