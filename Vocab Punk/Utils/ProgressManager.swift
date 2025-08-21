//
//  ProgressManager.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import Foundation

class ProgressManager {
    static let shared = ProgressManager()
    private init() {}
    
    // Кэш для прогресса (по email)
    private var cachedProgress: [String: [String: WordProgress]] = [:]
    
    // MARK: - Загрузка прогресса
    func loadProgress(for email: String) -> [String: WordProgress] {
        // Если прогресс уже есть в кэше, обновляем decay для слов
        if var cached = cachedProgress[email] {
            cached = applyDecay(to: cached, email: email)
            cachedProgress[email] = cached
            return cached
        }

        // Загружаем из UserDefaults
        let key = "progress_\(email)"
        if let data = UserDefaults.standard.data(forKey: key),
           var progress = try? JSONDecoder().decode([String: WordProgress].self, from: data) {
            progress = applyDecay(to: progress, email: email)
            cachedProgress[email] = progress
            return progress
        }
        return [:]
    }
    
    // MARK: - Сохранение прогресса
    func saveProgress(for email: String, progress: [String: WordProgress]) {
        let key = "progress_\(email)"
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: key)
            cachedProgress[email] = progress
        }
    }
    
    // MARK: - Обновление прогресса при свайпе
    func updateProgress(for email: String, wordID: String, swipeUp: Bool) {
        var progress = loadProgress(for: email)
        var record = progress[wordID] ?? WordProgress(id: wordID)

        // decay перед изменением
        record.decayIfNeeded()
        
        if swipeUp {
            record.swipeUp()
        } else {
            record.swipeDown()
        }
        progress[wordID] = record
        saveProgress(for: email, progress: progress)
        
        // Отправляем на сервер асинхронно
        Task {
            do {
                try await UserService.shared.uploadProgress(email: email, progress: [wordID: record])
                print("✅ Прогресс пользователя \(email) синхронизирован с сервером, id: \(wordID)")
            } catch {
                print("❌ Ошибка отправки прогресса: \(error)")
            }
        }
    }
    
    // MARK: - Средний прогресс по уровню
    func averageProgress(for level: String, lang: String, userProgress: [String: WordProgress]) -> Double {
        let cards = DictionaryManager.shared.loadDictionary(lang: lang, level: level)
        guard !cards.isEmpty else { return 0 }

        let totalScore = cards.reduce(0) { sum, card in
            sum + (userProgress[card.id]?.memoryScore ?? 0)
        }
        return Double(totalScore) / Double(cards.count)
    }

    // MARK: - Средний прогресс по всем уровням
    func averageProgressByLevel(email: String) -> [String:[String: Double]] {
        var userProgress = loadProgress(for: email)
        userProgress = applyDecay(to: userProgress, email: email)
        
        let levels = DictionaryManager.shared.availableLevels()
        var result: [String: [String: Double]] = [:]
        
        for (lang, levelList) in levels {
            var list: [String: Double] = [:]
            for level in levelList {
                list[level] = averageProgress(for: level, lang: lang, userProgress: userProgress)
            }
            result[lang] = list
        }
        
        return result
    }
    
    // MARK: - Очистка кэша
    func clearCache(for email: String, removeData: Bool = false) {
        cachedProgress.removeValue(forKey: email)
        
        guard removeData else { return }
        saveProgress(for: email, progress: [:])
    }

    func clearAllCache() {
        cachedProgress.removeAll()
    }

    // MARK: - decay для всех слов
    private func applyDecay(to progress: [String: WordProgress], email: String) -> [String: WordProgress] {
        var updatedProgress = progress
        var changed = false
        
        for (id, var record) in progress {
            let oldScore = record.memoryScore
            record.decayIfNeeded()
            if record.memoryScore != oldScore {
                updatedProgress[id] = record
                changed = true
            }
        }

        if changed {
            saveProgress(for: email, progress: updatedProgress)
        }
        return updatedProgress
    }
}
