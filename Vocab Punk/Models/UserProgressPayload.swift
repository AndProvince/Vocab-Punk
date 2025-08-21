//
//  UserProgressPayload.swift
//  Vocab Punk
//
//  Created by Андрей on 20.08.2025.
//

struct UserProgressPayload: Codable {
    let email: String
    let progress: [String: WordProgress] // wordID -> score
}
