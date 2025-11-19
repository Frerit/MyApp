//
//  TokenManager.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation

// MARK: - Token Manager Protocol
protocol TokenManagerProtocol {
    func saveToken(_ token: String, type: TokenType)
    func getToken(type: TokenType) -> String?
    func deleteToken(type: TokenType)
    func isTokenValid(type: TokenType) -> Bool
    func refreshTokenIfNeeded() async throws
}

// MARK: - Token Type
enum TokenType {
    case access
    case refresh
    
    var keychainKey: String {
        switch self {
        case .access:
            return "access_token"
        case .refresh:
            return "refresh_token"
        }
    }
    
    var expirationKey: String {
        switch self {
        case .access:
            return "access_token_expiration"
        case .refresh:
            return "refresh_token_expiration"
        }
    }
}

// MARK: - Token Manager
final class TokenManager: TokenManagerProtocol {
    
    private let keychainService: KeychainServiceProtocol
    private let userDefaults: UserDefaults
    
    init(keychainService: KeychainServiceProtocol = KeychainService(),
         userDefaults: UserDefaults = .standard) {
        self.keychainService = keychainService
        self.userDefaults = userDefaults
    }
    
    func saveToken(_ token: String, type: TokenType) {
        keychainService.save(key: type.keychainKey, value: token)
        
        // Decode JWT and save expiration time
        if let expiration = decodeTokenExpiration(token) {
            userDefaults.set(expiration.timeIntervalSince1970, forKey: type.expirationKey)
        }
    }
    
    func getToken(type: TokenType) -> String? {
        return keychainService.get(key: type.keychainKey)
    }
    
    func deleteToken(type: TokenType) {
        keychainService.delete(key: type.keychainKey)
        userDefaults.removeObject(forKey: type.expirationKey)
    }
    
    func isTokenValid(type: TokenType) -> Bool {
        guard let _ = getToken(type: type) else {
            return false
        }
        
        let expirationTimestamp = userDefaults.double(forKey: type.expirationKey)
        guard expirationTimestamp > 0 else {
            return false
        }
        
        let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
        
        // Add 5 minute buffer before expiration
        let bufferDate = expirationDate.addingTimeInterval(-300)
        
        return Date() < bufferDate
    }
    
    func refreshTokenIfNeeded() async throws {
        guard !isTokenValid(type: .access) else {
            return
        }
        
        guard isTokenValid(type: .refresh), 
              let refreshToken = getToken(type: .refresh) else {
            throw TokenError.refreshTokenExpired
        }
        
        // Here you would call your auth service to refresh the token
        // For now, we'll just throw an error indicating refresh is needed
        throw TokenError.refreshNeeded
    }
    
    // MARK: - Private Methods
    private func decodeTokenExpiration(_ token: String) -> Date? {
        let segments = token.components(separatedBy: ".")
        guard segments.count > 1 else {
            return nil
        }
        
        let payloadSegment = segments[1]
        var base64 = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
    }
}

// MARK: - Token Error
enum TokenError: LocalizedError {
    case refreshTokenExpired
    case refreshNeeded
    case invalidToken
    
    var errorDescription: String? {
        switch self {
        case .refreshTokenExpired:
            return "Refresh token has expired"
        case .refreshNeeded:
            return "Token refresh is needed"
        case .invalidToken:
            return "Invalid token format"
        }
    }
}
