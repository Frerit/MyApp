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
    
    // MARK: - View
    var body: some View {
        VStack {
            Text("iOS App")
                .font(.largeTitle).foregroundColor(Color.white)
                .padding([.top, .bottom], 40)
                .shadow(radius: 10.0, x: 20, y: 10)
            
            Image("iosapptemplate")
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10.0, x: -20, y: 10)
                .padding(.bottom, 50)
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("Email", text: password)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                
                SecureField("Password", text: self.$password)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
            }.padding([.leading, .trailing], 27.5)
            
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
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                Button(action: {}) {
                    Text("Sign Up")
                        .foregroundColor(.black)
                }
            }
        }
        .background(
            LinearGradient(gradient:
                Gradient(colors:
                            [.purple, .blue]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
         .edgesIgnoringSafeArea(.all))
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
