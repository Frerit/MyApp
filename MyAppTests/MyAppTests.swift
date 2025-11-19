//
//  MyAppTests.swift
//  MyAppTests
//
//  Created by Julian on 19/07/23.
//

import XCTest
@testable import MyApp

// MARK: - Mock Network Service
final class MockNetworkService: NetworkService {
    var shouldFail = false
    var callCount = 0
    
    override func login(email: String, password: String) async throws -> LoginResponse {
        callCount += 1
        
        if shouldFail {
            throw NetworkError.serverError
        }
        
        return LoginResponse(token: "test_token", userId: "123", email: email)
    }
}

// MARK: - Mock Keychain Service
final class MockKeychainService: KeychainService {
    private var storage: [String: String] = [:]
    
    override func save(key: String, value: String) {
        storage[key] = value
    }
    
    override func get(key: String) -> String? {
        return storage[key]
    }
    
    override func delete(key: String) {
        storage.removeValue(forKey: key)
    }
}

// MARK: - Authentication Service Tests
final class AuthenticationServiceTests: XCTestCase {
    
    var sut: AuthenticationService!
    var mockNetworkService: MockNetworkService!
    var mockKeychainService: MockKeychainService!
    
    override func setUpWithError() throws {
        mockNetworkService = MockNetworkService()
        mockKeychainService = MockKeychainService()
        sut = AuthenticationService(
            networkService: mockNetworkService,
            keychainService: mockKeychainService
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockNetworkService = nil
        mockKeychainService = nil
    }
    
    func testLoginSuccess() async throws {
        // When
        let response = try await sut.login(email: "test@example.com", password: "password123")
        
        // Then
        XCTAssertEqual(response.token, "test_token")
        XCTAssertEqual(response.email, "test@example.com")
        XCTAssertEqual(mockNetworkService.callCount, 1)
        XCTAssertNotNil(mockKeychainService.get(key: "auth_token"))
    }
    
    func testLoginFailure() async throws {
        // Given
        mockNetworkService.shouldFail = true
        
        // When/Then
        do {
            _ = try await sut.login(email: "test@example.com", password: "wrong")
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testLogout() {
        // Given
        mockKeychainService.save(key: "auth_token", value: "test")
        
        // When
        sut.logout()
        
        // Then
        XCTAssertNil(mockKeychainService.get(key: "auth_token"))
    }
}

// MARK: - Login ViewModel Tests
final class LoginViewModelTests: XCTestCase {
    
    var sut: LoginViewModel!
    var mockAuthService: AuthenticationService!
    
    @MainActor
    override func setUpWithError() throws {
        let mockNetworkService = MockNetworkService()
        mockAuthService = AuthenticationService(
            networkService: mockNetworkService,
            keychainService: MockKeychainService()
        )
        sut = LoginViewModel(authService: mockAuthService)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAuthService = nil
    }
    
    @MainActor
    func testFormValidation() {
        // Given
        sut.email = ""
        sut.password = ""
        
        // Then
        XCTAssertFalse(sut.isFormValid)
        
        // When
        sut.email = "test@example.com"
        sut.password = "password123"
        
        // Then
        XCTAssertTrue(sut.isFormValid)
    }
    
    @MainActor
    func testLoginSuccess() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        
        // When
        await sut.login()
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
}
