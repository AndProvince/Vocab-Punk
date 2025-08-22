//
//  UserService.swift
//  Vocab Punk
//
//  Created by Андрей on 20.08.2025.
//

import Foundation

struct ServerErrorResponse: Codable {
    let error: String
}

final class UserService {
    static let shared = UserService()
    private init() {}
    
    private var baseURL: String {
        DictionaryUpdateService.shared.hostURL
    }
    
    // Регистрация
    func registerUser(email: String, password: String) async throws -> String { // -> email
        let url = URL(string: "\(baseURL)/clients/register")!
        let body = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200..<300).contains(httpResponse.statusCode) {
            // Парсим ответ
            struct LoginResponse: Codable { let email: String; let status: String }
            let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
            return decoded.email
        } else {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: serverError.error])
            } else {
                throw URLError(.badServerResponse)
            }
        }
    }
    
    // Вход
    func loginUser(email: String, password: String) async throws -> String { // -> email
        let url = URL(string: "\(baseURL)/clients/login")!
        let body = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200..<300).contains(httpResponse.statusCode) {
            // Парсим ответ
            struct LoginResponse: Codable { let email: String; let status: String }
            let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
            return decoded.email
        } else {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: serverError.error])
            } else {
                throw URLError(.badServerResponse)
            }
        }
    }
    
    // Отправка прогресса
    func uploadProgress(email: String, progress: [String: WordProgress]) async throws {
        let url = URL(string: "\(baseURL)/clients/progress")!
        let payload = UserProgressPayload(email: email, progress: progress)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // Загрузка прогресса
    func fetchProgress(email: String) async throws -> [String: WordProgress] {
        let url = URL(string: "\(baseURL)/clients/progress?email=\(email)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let payload = try JSONDecoder().decode(UserProgressPayload.self, from: data)
        return payload.progress
    }
}
