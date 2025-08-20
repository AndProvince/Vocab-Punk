//
//  DictionaryUpdateScheduler.swift
//  Vocab Punk
//
//  Created by Андрей on 14.08.2025.
//

import Foundation

final class DictionaryUpdateScheduler {
    static let shared = DictionaryUpdateScheduler()
    
    private var timer: Timer?
    private let interval: TimeInterval = 60 * 10 // каждые N минут

    private init() {}
    
    func start() {
        // Если таймер уже запущен — не перезапускаем
        guard timer == nil else { return }
        
        // Сразу проверим при старте
        Task {
            await DictionaryUpdateService.shared.checkAndUpdateIfNeeded()
        }
        
        // Запускаем периодическую проверку
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task {
                await DictionaryUpdateService.shared.checkAndUpdateIfNeeded()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
