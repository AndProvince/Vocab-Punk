//
//  UserService.swift
//  Vocab Punk
//
//  Created by Андрей on 20.08.2025.
//

import Foundation

final class UserService {
    static let shared = UserService()
    private init() {}
    
    private var baseURL: String {
        DictionaryUpdateService.shared.hostURL
    }
    
    // Регистрация
    func registerUser(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/clients/register")!
        let body = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
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
