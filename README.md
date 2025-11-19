# MyApp - iOS Technical Test

## 📱 Overview

This is a comprehensive iOS application designed as a technical assessment for senior iOS developers. The project includes authentication, networking, data persistence, and security features with intentional bugs and architectural challenges.

## 🎯 Purpose

This codebase serves as a technical interview challenge containing **51 intentional errors** across different complexity levels:
- Critical compilation errors
- Architecture violations
- Security vulnerabilities
- Performance issues
- Testing gaps
- DevOps configuration problems

## 🏗️ Architecture

### MVVM Pattern
- **Models**: User, LoginRequest, LoginResponse
- **ViewModels**: LoginViewModel with Combine publishers
- **Views**: SwiftUI LoginView and ContentView
- **Services**: NetworkService, AuthenticationService, KeychainService, BiometricAuthService

### Key Features
- ✅ Email/Password Authentication
- ✅ Biometric Authentication (Face ID / Touch ID)
- ✅ JWT Token Management
- ✅ Secure Keychain Storage
- ✅ Core Data Persistence
- ✅ Form Validation
- ✅ Async/Await Networking
- ✅ Dependency Injection
- ✅ Unit Tests with Mocks

## 📁 Project Structure

```
MyApp/
├── Models/
│   └── User.swift                      # Data models
├── ViewModels/
│   └── LoginViewModel.swift            # MVVM ViewModels
├── Views/
│   └── ContentView.swift               # SwiftUI Views
├── Services/
│   ├── NetworkService.swift            # API calls
│   ├── AuthenticationService.swift     # Auth logic
│   ├── KeychainService.swift           # Secure storage
│   ├── BiometricAuthService.swift      # Face ID / Touch ID
│   ├── ValidationService.swift         # Input validation
│   └── TokenManager.swift              # JWT handling
├── Persistence/
│   ├── PersistenceController.swift     # Core Data setup
│   └── UserDataManager.swift           # Data operations
└── MyApp.xcdatamodeld/
    └── MyApp.xcdatamodel/              # Core Data model

MyAppTests/
└── MyAppTests.swift                    # Unit tests

fastlane/
├── Appfile                             # App config
└── Fastfile                            # CI/CD lanes
```

## 🚀 Getting Started

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Ruby 2.7+ (for Fastlane)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd MyApp
```

2. Install dependencies:
```bash
bundle install
```

3. Open the project:
```bash
open MyApp.xcodeproj
```

### Running the App

#### Via Xcode
1. Select a simulator or device
2. Press `⌘ + R` to build and run

#### Via Fastlane
```bash
bundle exec fastlane build
```

## 🧪 Testing

### Run Tests via Xcode
```bash
⌘ + U
```

### Run Tests via Fastlane
```bash
bundle exec fastlane test
```

### Test Coverage
- AuthenticationService: Unit tests with mocks
- LoginViewModel: State management tests
- UserDataManager: Core Data tests
- Validation: Input validation tests

## 🔐 Security Features

### Keychain Integration
- Secure token storage
- Access control with biometrics
- Automatic cleanup on logout

### Biometric Authentication
- Face ID support
- Touch ID support
- Fallback to passcode

### JWT Token Management
- Token expiration handling
- Automatic refresh
- Secure storage

### Input Validation
- Email format validation
- Strong password requirements
- SQL injection prevention
- XSS protection

## 🐛 Known Issues (For Testing Purposes)

This project contains intentional bugs for assessment. See `PRUEBA_TECNICA.md` for details.

**Categories:**
- 🔴 Critical Errors (10)
- 🟡 Architecture Issues (8)
- 🔐 Security Vulnerabilities (15)
- ⚡ Performance Problems (7)
- 🧪 Testing Gaps (6)
- 🚀 DevOps Issues (5)

**Total: 51 intentional errors**

## 📚 Documentation

- **[PRUEBA_TECNICA.md](PRUEBA_TECNICA.md)**: Complete technical test description
- **[SOLUCION_COMPLETA.md](SOLUCION_COMPLETA.md)**: Full solution guide with all fixes

## 🛠️ Technologies Used

- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Networking**: URLSession with async/await
- **Persistence**: Core Data
- **Security**: Keychain, LocalAuthentication
- **Reactive**: Combine
- **Testing**: XCTest
- **CI/CD**: Fastlane
- **Dependency Management**: Swift Package Manager

## 📝 Code Style

The project follows:
- Swift API Design Guidelines
- SwiftLint rules (to be configured)
- Clean Code principles
- SOLID principles

## 🤝 Contributing

This is a technical assessment project. Please do not submit pull requests.

## 📄 License

This project is for educational and assessment purposes only.

## 👥 Authors

Created for CENCO technical interviews.

## 📞 Support

For questions about the technical test, contact the hiring team.

---

## 🎓 Learning Objectives

Completing this technical test will demonstrate proficiency in:

1. **Swift Language Mastery**
   - Modern Swift features (async/await, generics, protocols)
   - Memory management and ARC
   - Error handling patterns

2. **iOS Frameworks**
   - SwiftUI lifecycle and state management
   - Core Data for persistence
   - URLSession for networking
   - LocalAuthentication for biometrics
   - Security framework for Keychain

3. **Architecture & Design**
   - MVVM pattern implementation
   - Dependency injection
   - Protocol-oriented programming
   - Clean architecture principles

4. **Security Best Practices**
   - Secure data storage
   - Authentication flows
   - Input validation
   - Token management

5. **Testing**
   - Unit testing with XCTest
   - Mocking and dependency injection
   - Async testing
   - Test coverage

6. **DevOps**
   - Fastlane configuration
   - CI/CD setup
   - Build automation

---

**Good luck! 🚀**
