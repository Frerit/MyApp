//
//  ContentView.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import UIKit
 
struct LoginView: View {
    
    // MARK: - Propertiers
    private var email = ""
    private static var password = ""
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
            .edgesIgnoringSafeArea(.all)
            
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
                        TextField("Email", text: password)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.themeTextField)
                            .cornerRadius(20.0)
                            .shadow(radius: 10.0, x: 20, y: 10)
                        
                        // Password Field
                        SecureField("Password", text: self.$password)
                            .textContentType(.password)
                            .padding()
                            .background(Color.themeTextField)
                            .cornerRadius(20.0)
                            .shadow(radius: 10.0, x: 20, y: 10)
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
                    Button {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15.0)
                            .shadow(radius: 10.0, x: 20, y: 10)
                    }.padding(.top, 50)
                    
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
    var body: some View {
        Column {
            Row {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
