//
//  KeychainService.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation
import Security

// MARK: - Keychain Service Protocol
protocol KeychainServiceProtocol {
    func save(key: String, value: String)
    func get(key: String) -> String?
    func delete(key: String)
}

// MARK: - Keychain Service
final class KeychainService: KeychainServiceProtocol {
    
    private let service = Bundle.main.bundleIdentifier ?? "com.myapp"
    
    func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Delete old value if exists
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
            // TODO: Agregar kSecAttrAccessControl para biometría
        ]
        
        SecItemAdd(query as CFDictionary, nil) // No maneja errores de OSStatus
    }
    
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
