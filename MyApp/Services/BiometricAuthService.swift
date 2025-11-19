//
//  BiometricAuthService.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation
import LocalAuthentication

// MARK: - Biometric Auth Service Protocol
protocol BiometricAuthServiceProtocol {
    func canUseBiometrics() -> Bool
    func authenticate(reason: String) async throws -> Bool
}

// MARK: - Biometric Auth Service
final class BiometricAuthService: BiometricAuthServiceProtocol {
    
    private let context = LAContext()
    
    func canUseBiometrics() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            throw BiometricError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                if let error = error {
                    continuation.resume(throwing: BiometricError.authenticationFailed(error))
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
}

// MARK: - Biometric Error
enum BiometricError: LocalizedError {
    case notAvailable
    case authenticationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available"
        case .authenticationFailed(let error):
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
}
