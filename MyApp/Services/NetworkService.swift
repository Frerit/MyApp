//
//  NetworkService.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .unauthorized:
            return "Unauthorized"
        case .serverError:
            return "Server error"
        }
    }
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let token: String
    let userId: String
    let email: String
}

// MARK: - Network Service
class NetworkService {
    
    func login(email: String, password: String) async throws -> LoginResponse {
        // Simular llamada a API
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Validación simple
        if email.isEmpty || password.isEmpty {
            throw NetworkError.invalidResponse
        }
        
        if password.count < 6 {
            throw NetworkError.unauthorized
        }
        
        // Simular respuesta exitosa
        return LoginResponse(
            token: "mock_token_123",
            userId: "user_123",
            email: email
        )
    }
}
