//
//  WordProgress.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import Foundation

struct WordProgress: Codable, Identifiable {
    let id: String           // UUID или хэш слова
    var memoryScore: Int     // 0–100
    var lastReviewed: Date
    var swipeUpCount: Int
    var swipeDownCount: Int
    
    init(id: String) {
        self.id = id
        self.memoryScore = 0
        self.lastReviewed = Date()
        self.swipeUpCount = 0
        self.swipeDownCount = 0
    }
    
    mutating func swipeUp() {
        memoryScore = min(100, memoryScore + 20)
        swipeUpCount += 1
        lastReviewed = Date()
    }
    
    mutating func swipeDown() {
        memoryScore = max(0, memoryScore - 20)
        swipeDownCount += 1
        lastReviewed = Date()
    }
    
    mutating func decayIfNeeded() {
        let weeksPassed = Int(Date().timeIntervalSince(lastReviewed) / (60 * 60 * 24 * 7))
        if weeksPassed >= 1 {
            memoryScore = max(0, memoryScore - 10)
            lastReviewed = Date()
        }
    }
}
