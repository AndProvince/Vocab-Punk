//
//  FlashcardsViewModel.swift
//  Vocab Punk
//
//  Created by Андрей on 21.07.2025.
//

import Foundation
import Combine

class FlashcardsViewModel: ObservableObject {
    @Published var cards: [WordCard] = []
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false

    let userEmail: String
    let lang: String
    let level: String

    private var cancellables = Set<AnyCancellable>()
    public var progress: [String: WordProgress] = [:]

    init(email: String, lang: String = "EN", level: String = "A1") {
        self.userEmail = email
        self.cards = []
        self.progress = [:]
        self.currentIndex = 0
        self.level = level
        self.lang = lang

        loadCards()
        self.progress = ProgressManager.shared.loadProgress(for: email)
        self.currentIndex = self.selectNextCardIndex()
        
        // Подпишемся на обновление словарей
        NotificationCenter.default.publisher(for: .dictionariesDidUpdate)
            .sink { [weak self] _ in
                self?.reloadDictionaries()
            }
            .store(in: &cancellables)
    }
    
    func loadCards() {
        cards = DictionaryManager.shared.loadDictionary(lang: lang, level: level)
    }
    
    func reloadDictionaries() {
        DictionaryManager.shared.clearCache() // очищаем память (на всякий случай)
        loadCards()
        currentIndex = selectNextCardIndex()
    }
    
    var currentCard: WordCard? {
        guard !cards.isEmpty else { return nil }
        return cards[currentIndex]
    }
    
    func flipCard() {
        isFlipped.toggle()
    }

    func nextCard(swipeUp: Bool) {
        guard let card = currentCard else { return }
        ProgressManager.shared.updateProgress(for: userEmail, wordID: card.id, swipeUp: swipeUp)
        progress = ProgressManager.shared.loadProgress(for: userEmail)
        currentIndex = selectNextCardIndex()
        isFlipped = false
    }

    // MARK: - Card selection with probability
    private func selectNextCardIndex() -> Int {
        if cards.isEmpty { return 0 }
        
        // Создаем список с весами, где вес = (100 - memoryScore)
        let weights: [Double] = cards.map { card in
            let record = progress[card.id] ?? WordProgress(id: card.id)
            return Double(100 - record.memoryScore)
        }
        
        let totalWeight = weights.reduce(0, +)
        guard totalWeight > 0 else {
            return Int.random(in: 0..<cards.count)
        }
        
        let randomValue = Double.random(in: 0..<totalWeight)
        var cumulative: Double = 0
        
        for (index, weight) in weights.enumerated() {
            cumulative += weight
            if randomValue <= cumulative {
                return index
            }
        }
        return 0
    }
    
    // MARK: - Helpers
    func resetProgress() {
        ProgressManager.shared.saveProgress(for: userEmail, progress: [:])
        progress = [:]
        currentIndex = 0
        isFlipped = false
    }
}
