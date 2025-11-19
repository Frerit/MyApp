//
//  ValidationService.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation

// MARK: - Validation Service Protocol
protocol ValidationServiceProtocol {
    func validateEmail(_ email: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    func validateRequired(_ value: String, fieldName: String) -> ValidationResult
    func validateLength(_ value: String, min: Int, max: Int, fieldName: String) -> ValidationResult
}

// MARK: - Validation Result
struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
    
    static var valid: ValidationResult {
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    static func invalid(_ message: String) -> ValidationResult {
        return ValidationResult(isValid: false, errorMessage: message)
    }
}

// MARK: - Validation Service
final class ValidationService: ValidationServiceProtocol {
    
    // Email validation with RFC 5322 compliant regex
    func validateEmail(_ email: String) -> ValidationResult {
        guard !email.isEmpty else {
            return .invalid("Email is required")
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: email) else {
            return .invalid("Please enter a valid email address")
        }
        
        return .valid
    }
    
    // Password validation with security requirements
    func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .invalid("Password is required")
        }
        
        guard password.count >= 8 else {
            return .invalid("Password must be at least 8 characters long")
        }
        
        guard password.count <= 128 else {
            return .invalid("Password must not exceed 128 characters")
        }
        
        // Check for at least one uppercase letter
        let uppercaseRegex = ".*[A-Z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) else {
            return .invalid("Password must contain at least one uppercase letter")
        }
        
        // Check for at least one lowercase letter
        let lowercaseRegex = ".*[a-z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password) else {
            return .invalid("Password must contain at least one lowercase letter")
        }
        
        // Check for at least one number
        let numberRegex = ".*[0-9]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password) else {
            return .invalid("Password must contain at least one number")
        }
        
        // Check for at least one special character
        let specialCharRegex = ".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", specialCharRegex).evaluate(with: password) else {
            return .invalid("Password must contain at least one special character")
        }
        
        return .valid
    }
    
    // Generic required field validation
    func validateRequired(_ value: String, fieldName: String) -> ValidationResult {
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .invalid("\(fieldName) is required")
        }
        
        return .valid
    }
    
    // Generic length validation
    func validateLength(_ value: String, min: Int, max: Int, fieldName: String) -> ValidationResult {
        let length = value.count
        
        guard length >= min else {
            return .invalid("\(fieldName) must be at least \(min) characters")
        }
        
        guard length <= max else {
            return .invalid("\(fieldName) must not exceed \(max) characters")
        }
        
        return .valid
    }
}
