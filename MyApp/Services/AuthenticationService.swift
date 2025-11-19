//
//  AuthenticationService.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation

// MARK: - Authentication Service
class AuthenticationService {
    
    private let networkService: NetworkService
    private let keychainService: KeychainService
    
    init(networkService: NetworkService = NetworkService(),
         keychainService: KeychainService = KeychainService()) {
        self.networkService = networkService
        self.keychainService = keychainService
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let response = try await networkService.login(email: email, password: password)
        
        // Save token
        keychainService.save(key: "auth_token", value: response.token)
        
        return response
    }
    
    func logout() {
        // TODO: Invalidar token en el servidor
        keychainService.delete(key: "auth_token")
    }
    
    func isAuthenticated() -> Bool {
        return keychainService.get(key: "auth_token") != nil
    }
}
