//
//  LoginViewModel.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation
import SwiftUI

// MARK: - Login View Model
@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let authService: AuthenticationService
    
    init(authService: AuthenticationService = AuthenticationService()) {
        self.authService = authService
    }
    
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    func login() async {
        guard isFormValid else {
            errorMessage = "Please fill all fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.login(email: email, password: password)
            isAuthenticated = true
        } catch let error as NetworkError {
            errorMessage = error.message
        } catch {
            errorMessage = "An error occurred"
        }
        
        isLoading = false
    }
}
