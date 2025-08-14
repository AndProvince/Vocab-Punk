//
//  FlashcardsSetsViewModel.swift
//  Vocab Punk
//
//  Created by Андрей on 14.08.2025.
//

import Foundation
import Combine

class FlashcardsSetsViewModel: ObservableObject {
    @Published var levels: [String: [String]] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        levels = DictionaryManager.shared.availableLevels()
        
        // Подпишемся на обновление словарей
        NotificationCenter.default.publisher(for: .dictionariesDidUpdate)
            .sink { [weak self] _ in
                self?.reloadLevels()
            }
            .store(in: &cancellables)
    }
    
    func reloadLevels() {
        DispatchQueue.main.async {
            self.levels = DictionaryManager.shared.availableLevels()
        }
    }
    
}
