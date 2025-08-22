//
//  AuthManager.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import Foundation

final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private let loggedInEmailKey = "loggedInEmail"
    
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var currentEmail: String?
    
    private init() {
        if let savedEmail = UserDefaults.standard.string(forKey: loggedInEmailKey) {
            self.currentEmail = savedEmail
            self.isLoggedIn = true
        }
    }
    
    // MARK: - Регистрация
    func register(email: String, password: String) async throws {
        let userEmail = try await UserService.shared.registerUser(email: email, password: password.sha256())
        setLoggedIn(email: userEmail)
    }
    
    // MARK: - Вход
    func login(email: String, password: String) async throws {
        let userEmail = try await UserService.shared.loginUser(email: email, password: password.sha256())
        setLoggedIn(email: userEmail)
    }
    
    // MARK: - Выход
    func logout() {
        UserDefaults.standard.removeObject(forKey: loggedInEmailKey)
        self.currentEmail = nil
        self.isLoggedIn = false
    }
    
    // MARK: - Приватные методы
    private func setLoggedIn(email: String) {
        UserDefaults.standard.set(email, forKey: loggedInEmailKey)
        self.currentEmail = email
        self.isLoggedIn = true
    }
}
