//
//  ContentView.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import SwiftUI
 
struct LoginView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: LoginViewModel
    @State private var showingSignUp = false
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("iOS App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .shadow(radius: 10.0, x: 20, y: 10)
                    
                    // App Icon
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10.0, x: -20, y: 10)
                        .padding(.bottom, 30)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 5) {
                            TextField("Email", text: $viewModel.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.themeTextField)
                                .cornerRadius(15.0)
                                .shadow(radius: 5.0, x: 0, y: 2)
                            
                            if let emailError = viewModel.emailError {
                                Text(emailError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.leading, 5)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 5) {
                            SecureField("Password", text: $viewModel.password)
                                .textContentType(.password)
                                .padding()
                                .background(Color.themeTextField)
                                .cornerRadius(15.0)
                                .shadow(radius: 5.0, x: 0, y: 2)
                            
                            if let passwordError = viewModel.passwordError {
                                Text(passwordError)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.leading, 5)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                    }
                    
                    // Sign In Button
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.green : Color.gray)
                        .cornerRadius(15.0)
                        .shadow(radius: 5.0, x: 0, y: 5)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    
                    // Biometric Authentication
                    if viewModel.showBiometricAuth {
                        Button(action: {
                            Task {
                                await viewModel.authenticateWithBiometrics()
                            }
                        }) {
                            HStack {
                                Image(systemName: "faceid")
                                Text("Sign In with Face ID")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15.0)
                        }
                        .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                    
                    // Sign Up Link
                    HStack(spacing: 5) {
                        Text("Don't have an account?")
                            .foregroundColor(.white)
                        Button(action: {
                            showingSignUp = true
                        }) {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showingSignUp) {
            Text("Sign Up View")
        }
    }
}

extension Color {
    static var themeTextField: Color {
        return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
    }
}

struct ContentView: View {
    @StateObject private var viewModel: LoginViewModel
    
    init() {
        let networkService = NetworkService()
        let authService = AuthenticationService(networkService: networkService)
        _viewModel = StateObject(wrappedValue: LoginViewModel(authService: authService))
    }
    
    var body: some View {
        LoginView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
