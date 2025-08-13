//
//  LevelColorManager.swift
//  Vocab Punk
//
//  Created by Андрей on 25.07.2025.
//

import SwiftUI

struct LevelColorScheme {
    let frontColors: [Color]    // Цвета передней стороны карточки
    let backColors: [Color]     // Цвета задней стороны карточки
    let buttonColors: [Color]   // Цвета кнопки уровня
}

class LevelColorManager {
    static let shared = LevelColorManager()
    
    private let colorSchemes: [String: LevelColorScheme] = [
        "A1": LevelColorScheme(
            frontColors: [Color.blue.opacity(0.7), Color.teal.opacity(0.7)],
            backColors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)],
            buttonColors: [Color.blue, Color.teal]
        ),
        "A2": LevelColorScheme(
            frontColors: [Color.teal.opacity(0.7), Color.cyan.opacity(0.7)],
            backColors: [Color.orange.opacity(0.8), Color.pink.opacity(0.8)],
            buttonColors: [Color.teal, Color.cyan]
        ),
        "B1": LevelColorScheme(
            frontColors: [Color.blue.opacity(0.7), Color.indigo.opacity(0.7)],
            backColors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.8)],
            buttonColors: [Color.blue, Color.indigo]
        ),
        "B2": LevelColorScheme(
            frontColors: [Color.indigo.opacity(0.7), Color.cyan.opacity(0.7)],
            backColors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)],
            buttonColors: [Color.indigo, Color.cyan]
        ),
        "C1": LevelColorScheme(
            frontColors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
            backColors: [Color.yellow.opacity(0.8), Color.red.opacity(0.8)],
            buttonColors: [Color.blue, Color.purple]
        ),
        "C2": LevelColorScheme(
            frontColors: [Color.purple.opacity(0.7), Color.cyan.opacity(0.7)],
            backColors: [Color.orange.opacity(0.8), Color.pink.opacity(0.8)],
            buttonColors: [Color.purple, Color.cyan]
        )
    ]
    
    func scheme(for level: String) -> LevelColorScheme {
        return colorSchemes[level] ?? LevelColorScheme(
            frontColors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
            backColors: [Color.orange.opacity(0.9), Color.red.opacity(0.9)],
            buttonColors: [Color.gray, Color.black]
        )
    }
}
