//
//  AuthenticationService.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation
import Combine

// MARK: - Authentication Service Protocol
protocol AuthenticationServiceProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func refreshToken(_ token: String) async throws -> LoginResponse
    func logout() async throws
    var isAuthenticated: Bool { get }
}

// MARK: - Authentication Service
final class AuthenticationService: AuthenticationServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let keychainService: KeychainServiceProtocol
    private let tokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"
    
    @Published private(set) var currentUser: User?
    
    var isAuthenticated: Bool {
        return keychainService.get(key: tokenKey) != nil
    }
    
    init(networkService: NetworkServiceProtocol,
         keychainService: KeychainServiceProtocol = KeychainService()) {
        self.networkService = networkService
        self.keychainService = keychainService
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        
        guard let body = try? JSONEncoder().encode(loginRequest) else {
            throw NetworkError.invalidURL
        }
        
        let endpoint = Endpoint(
            path: "/auth/login",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body,
            queryItems: nil
        )
        
        let response: LoginResponse = try await networkService.request(endpoint)
        
        // Save tokens securely
        keychainService.save(key: tokenKey, value: response.token)
        keychainService.save(key: refreshTokenKey, value: response.refreshToken)
        
        currentUser = response.user
        
        return response
    }
    
    func refreshToken(_ token: String) async throws -> LoginResponse {
        let refreshRequest = RefreshTokenRequest(refreshToken: token)
        
        guard let body = try? JSONEncoder().encode(refreshRequest) else {
            throw NetworkError.invalidURL
        }
        
        let endpoint = Endpoint(
            path: "/auth/refresh",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body,
            queryItems: nil
        )
        
        let response: LoginResponse = try await networkService.request(endpoint)
        
        // Update tokens
        keychainService.save(key: tokenKey, value: response.token)
        keychainService.save(key: refreshTokenKey, value: response.refreshToken)
        
        return response
    }
    
    func logout() async throws {
        keychainService.delete(key: tokenKey)
        keychainService.delete(key: refreshTokenKey)
        currentUser = nil
    }
}
