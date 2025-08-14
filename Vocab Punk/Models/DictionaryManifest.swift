//
//  DictionaryManifest.swift
//  Vocab Punk
//
//  Created by Андрей on 13.08.2025.
//

import Foundation

struct DictionaryManifest: Codable {
    let version: String
    let files: [DictionaryFile]
}

struct DictionaryFile: Codable {
    let language: String  // "EN"
    let level: String     // "A1"
    let url: URL          // прямая ссылка на JSON с картами слов
}
