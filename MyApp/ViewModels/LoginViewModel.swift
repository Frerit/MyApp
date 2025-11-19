//
//  LoginViewModel.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Login View Model
@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var showBiometricAuth: Bool = false
    
    // MARK: - Validation Properties
    @Published var emailError: String?
    @Published var passwordError: String?
    
    var isFormValid: Bool {
        return emailError == nil && 
               passwordError == nil && 
               !email.isEmpty && 
               !password.isEmpty
    }
    
    // MARK: - Dependencies
    private let authService: AuthenticationServiceProtocol
    private let biometricService: BiometricAuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(authService: AuthenticationServiceProtocol,
         biometricService: BiometricAuthServiceProtocol = BiometricAuthService()) {
        self.authService = authService
        self.biometricService = biometricService
        
        setupValidation()
        checkBiometricAvailability()
    }
    
    // MARK: - Setup
    private func setupValidation() {
        $email
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] email in
                self?.validateEmail(email)
            }
            .assign(to: &$emailError)
        
        $password
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] password in
                self?.validatePassword(password)
            }
            .assign(to: &$passwordError)
    }
    
    private func checkBiometricAvailability() {
        showBiometricAuth = biometricService.canUseBiometrics()
    }
    
    // MARK: - Validation Methods
    private func validateEmail(_ email: String) -> String? {
        guard !email.isEmpty else {
            return "Email is required"
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email) ? nil : "Invalid email format"
    }
    
    private func validatePassword(_ password: String) -> String? {
        guard !password.isEmpty else {
            return "Password is required"
        }
        
        guard password.count >= 8 else {
            return "Password must be at least 8 characters"
        }
        
        // Check for at least one uppercase, one lowercase, one number
        let uppercaseRegex = ".*[A-Z]+.*"
        let lowercaseRegex = ".*[a-z]+.*"
        let numberRegex = ".*[0-9]+.*"
        
        let hasUppercase = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password)
        let hasLowercase = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password)
        let hasNumber = NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password)
        
        if !hasUppercase || !hasLowercase || !hasNumber {
            return "Password must contain uppercase, lowercase, and number"
        }
        
        return nil
    }
    
    // MARK: - Actions
    func login() async {
        guard isFormValid else {
            errorMessage = "Please fix the errors before continuing"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.login(email: email, password: password)
            isAuthenticated = true
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func authenticateWithBiometrics() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let success = try await biometricService.authenticate(reason: "Login to MyApp")
            if success {
                // Here you would typically retrieve stored credentials
                // For now, we'll just mark as authenticated
                isAuthenticated = true
            } else {
                errorMessage = "Biometric authentication failed"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
