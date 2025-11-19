//
//  MyAppTests.swift
//  MyAppTests
//
//  Created by Julian on 19/07/23.
//

import XCTest
import Combine
@testable import MyApp

// MARK: - Mock Network Service
final class MockNetworkService: NetworkServiceProtocol {
    var shouldFail = false
    var mockResponse: Any?
    var requestCallCount = 0
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError(NSError(domain: "Mock", code: 0))
        }
        
        return response
    }
    
    func upload<T: Decodable>(data: Data, to endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        
        if shouldFail {
            throw NetworkError.serverError(500)
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError(NSError(domain: "Mock", code: 0))
        }
        
        return response
    }
}

// MARK: - Mock Keychain Service
final class MockKeychainService: KeychainServiceProtocol {
    private var storage: [String: String] = [:]
    
    func save(key: String, value: String) {
        storage[key] = value
    }
    
    func get(key: String) -> String? {
        return storage[key]
    }
    
    func delete(key: String) {
        storage.removeValue(forKey: key)
    }
}

// MARK: - Mock Biometric Service
final class MockBiometricService: BiometricAuthServiceProtocol {
    var canUseBiometricsResult = true
    var authenticateResult = true
    
    func canUseBiometrics() -> Bool {
        return canUseBiometricsResult
    }
    
    func authenticate(reason: String) async throws -> Bool {
        return authenticateResult
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
        // Given
        let mockUser = User(
            id: UUID(),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            avatar: nil,
            createdAt: Date(),
            isActive: true
        )
        
        let mockResponse = LoginResponse(
            token: "test_token",
            refreshToken: "refresh_token",
            user: mockUser,
            expiresIn: 3600
        )
        
        mockNetworkService.mockResponse = mockResponse
        
        // When
        let response = try await sut.login(email: "test@example.com", password: "Password123")
        
        // Then
        XCTAssertEqual(response.token, "test_token")
        XCTAssertEqual(response.user.email, "test@example.com")
        XCTAssertEqual(mockNetworkService.requestCallCount, 1)
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
    
    func testLogout() async throws {
        // Given
        mockKeychainService.save(key: "auth_token", value: "test")
        
        // When
        try await sut.logout()
        
        // Then
        XCTAssertNil(mockKeychainService.get(key: "auth_token"))
    }
}

// MARK: - Login ViewModel Tests
final class LoginViewModelTests: XCTestCase {
    
    var sut: LoginViewModel!
    var mockAuthService: AuthenticationService!
    var mockNetworkService: MockNetworkService!
    var mockBiometricService: MockBiometricService!
    
    @MainActor
    override func setUpWithError() throws {
        mockNetworkService = MockNetworkService()
        mockBiometricService = MockBiometricService()
        mockAuthService = AuthenticationService(
            networkService: mockNetworkService,
            keychainService: MockKeychainService()
        )
        sut = LoginViewModel(
            authService: mockAuthService,
            biometricService: mockBiometricService
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAuthService = nil
        mockNetworkService = nil
        mockBiometricService = nil
    }
    
    @MainActor
    func testEmailValidation() {
        // Given
        sut.email = "invalid-email"
        
        // Then
        XCTAssertNotNil(sut.emailError)
        XCTAssertFalse(sut.isFormValid)
        
        // When
        sut.email = "valid@example.com"
        
        // Wait for debounce
        let expectation = XCTestExpectation(description: "Debounce")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            XCTAssertNil(self.sut.emailError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor
    func testPasswordValidation() {
        // Given
        sut.password = "weak"
        
        // Then
        XCTAssertNotNil(sut.passwordError)
        XCTAssertFalse(sut.isFormValid)
    }
    
    @MainActor
    func testLoginSuccess() async {
        // Given
        let mockUser = User(
            id: UUID(),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            avatar: nil,
            createdAt: Date(),
            isActive: true
        )
        
        let mockResponse = LoginResponse(
            token: "test_token",
            refreshToken: "refresh_token",
            user: mockUser,
            expiresIn: 3600
        )
        
        mockNetworkService.mockResponse = mockResponse
        sut.email = "test@example.com"
        sut.password = "Password123"
        
        // When
        await sut.login()
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
    
    @MainActor
    func testBiometricAuthenticationAvailability() {
        // Given
        mockBiometricService.canUseBiometricsResult = true
        
        // When
        let newViewModel = LoginViewModel(
            authService: mockAuthService,
            biometricService: mockBiometricService
        )
        
        // Then
        XCTAssertTrue(newViewModel.showBiometricAuth)
    }
}

// MARK: - User Data Manager Tests
final class UserDataManagerTests: XCTestCase {
    
    var sut: UserDataManager!
    var persistenceController: PersistenceController!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        sut = UserDataManager(persistenceController: persistenceController)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        persistenceController = nil
    }
    
    func testSaveAndFetchUser() async throws {
        // Given
        let user = User(
            id: UUID(),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            avatar: nil,
            createdAt: Date(),
            isActive: true
        )
        
        // When
        try await sut.saveUser(user)
        let fetchedUser = try await sut.fetchUser(by: user.id)
        
        // Then
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?.email, user.email)
        XCTAssertEqual(fetchedUser?.firstName, user.firstName)
    }
    
    func testDeleteUser() async throws {
        // Given
        let user = User(
            id: UUID(),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            avatar: nil,
            createdAt: Date(),
            isActive: true
        )
        
        try await sut.saveUser(user)
        
        // When
        try await sut.deleteUser(user)
        let fetchedUser = try await sut.fetchUser(by: user.id)
        
        // Then
        XCTAssertNil(fetchedUser)
    }
    
    func testFetchAllUsers() async throws {
        // Given
        let users = [
            User(id: UUID(), email: "user1@test.com", firstName: "User", lastName: "One", avatar: nil, createdAt: Date(), isActive: true),
            User(id: UUID(), email: "user2@test.com", firstName: "User", lastName: "Two", avatar: nil, createdAt: Date(), isActive: true)
        ]
        
        for user in users {
            try await sut.saveUser(user)
        }
        
        // When
        let allUsers = try await sut.fetchAllUsers()
        
        // Then
        XCTAssertEqual(allUsers.count, 2)
    }
}
