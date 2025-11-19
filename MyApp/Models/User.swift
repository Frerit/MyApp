//
//  User.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable, Equatable {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String?
    let createdAt: Date
    var isActive: Bool
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
        case createdAt = "created_at"
        case isActive = "is_active"
    }
}

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let refreshToken: String
    let user: User
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
        case user
        case expiresIn = "expires_in"
    }
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
