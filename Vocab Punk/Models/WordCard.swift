//
//  WordCard.swift
//  Vocab Punk
//
//  Created by Андрей on 21.07.2025.
//

import Foundation

struct WordCard: Identifiable, Codable {
    let id: String
    let englishWord: String
    let englishIPA: String
    let englishIPAru: String
    let russianWord: String
    let russianIPA: String
    let russianIPAen: String
    let level: String
}

