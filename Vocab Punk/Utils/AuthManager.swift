//
//  AuthManager.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import Foundation
import Security

class AuthManager {
    static let shared = AuthManager()
    
    private let service = "com.vocabpunk.auth"
    private let sessionKey = "current_user_session"
    
    private init() {}
    
    // MARK: - Register user
    func register(email: String, password: String) -> Bool {
        guard getPassword(email: email) == nil else {
            // Такой пользователь уже существует
            return false
        }
        return saveCredentials(email: email, password: password)
    }
    
    // MARK: - Authenticate user
    func authenticate(email: String, password: String) -> Bool {
        guard let storedPassword = getPassword(email: email) else {
            return false
        }
        if storedPassword == password {
            saveCurrentUser(email: email)
            return true
        }
        return false
    }
    
    // MARK: - Save credentials
    private func saveCredentials(email: String, password: String) -> Bool {
        guard let passwordData = password.data(using: .utf8) else { return false }
        
        // Удаляем старые записи, если они были
        deleteCredentials(email: email)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData
        ]
        
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    // MARK: - Get password
    func getPassword(email: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Delete credentials
    func deleteCredentials(email: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    func getAllUsers() -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { $0[kSecAttrAccount as String] as? String }
    }
    
    // MARK: - Session Handling
    func saveCurrentUser(email: String) {
        // Удаляем старую сессию
        deleteCurrentUser()
        
        let data = email.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: sessionKey,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getCurrentUser() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: sessionKey,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteCurrentUser() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: sessionKey,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }

}
