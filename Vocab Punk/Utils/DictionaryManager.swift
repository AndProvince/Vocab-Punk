//
//  DictionaryManager.swift
//  Vocab Punk
//
//  Created by Андрей on 24.07.2025.
//

import Foundation

class DictionaryManager {
    static let shared = DictionaryManager()
    
    private init() {}
    
    // Загруженные словари кэшируются по уровню
    private var cachedDictionaries: [String: [String: [WordCard]]] = [:]
    
    // Документы/словари
    private var dictionariesDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("dictionaries", isDirectory: true)
    }
    
    /// Загрузка слов для указанного уровня (например, "A1")
    func loadDictionary(lang: String, level: String) -> [WordCard] {
        let L = level.uppercased()
        if let cached = cachedDictionaries[lang]?[level] {
            print("✅ Словарь уровня \(lang) \(level) загружен из кэша")
            return cached
        }
        
        // Загрузка из файлов
        let docURL = dictionariesDir
            .appendingPathComponent(lang, isDirectory: true)
            .appendingPathComponent("\(L)_words_full.json")
        if let words = try? load(from: docURL) {
            cache(words, lang: lang, level: L)
            print("✅ Словарь уровня \(lang) \(level) загружен из файла")
            return words
        }
        
        print("❌ JSON for \(lang) \(L) not found.")
        return []
    }
    
    /// Получить все уровни, доступные в проекте (ищет JSON-файлы в Bundle)
    /// Возвращает словарь вида ["EN": ["A1","B1"], "FR": ["A2"], ...]
    func availableLevels() -> [String: [String]] {
        var result: [String: Set<String>] = [:]

        // Документы
        if let langs = try? FileManager.default.contentsOfDirectory(at: dictionariesDir, includingPropertiesForKeys: nil) {
            for langDir in langs where langDir.hasDirectoryPath {
                let code = langDir.lastPathComponent
                if let files = try? FileManager.default.contentsOfDirectory(at: langDir, includingPropertiesForKeys: nil) {
                    for f in files where f.lastPathComponent.hasSuffix("_words_full.json") {
                        let level = f.deletingPathExtension().lastPathComponent
                            .replacingOccurrences(of: "_words_full", with: "")
                            .uppercased()
                        result[code, default: []].insert(level)
                    }
                }
            }
        }
        
        // Преобразуем Set -> [String], отсортируем
        var final: [String: [String]] = [:]
        for (lang, set) in result {
            final[lang] = Array(set).sorted()
        }
        return final
    }

    
    /// Очистка in-memory кэша + (опционально) файлов
    func clearCache(removeFiles: Bool = false) {
        cachedDictionaries.removeAll()

        guard removeFiles else { return }
        let fm = FileManager.default
        if fm.fileExists(atPath: dictionariesDir.path) {
            try? fm.removeItem(at: dictionariesDir)
        }
    }
    
    // MARK: - Helpers

    private func cache(_ words: [WordCard], lang: String, level: String) {
        var levels = cachedDictionaries[lang] ?? [:]
        levels[level] = words
        cachedDictionaries[lang] = levels
    }

    private func load(from url: URL) throws -> [WordCard] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([WordCard].self, from: data)
    }
}
