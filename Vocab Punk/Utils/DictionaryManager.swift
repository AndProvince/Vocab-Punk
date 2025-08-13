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
    
    /// Загрузка слов для указанного уровня (например, "A1")
    func loadDictionary(lang: String, level: String) -> [WordCard] {
        if let cached = cachedDictionaries[lang]?[level] {
            print("✅ Словарь уровня \(lang) \(level) загружен из кэша")
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "\(lang)_\(level.lowercased())_words_full", withExtension: "json") else {
            print("❌ JSON file for \(lang) \(level) not found.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let words = try decoder.decode([WordCard].self, from: data)
            
            // Если под ключом `lang` ещё нет словаря — создаём
            if cachedDictionaries[lang] == nil {
                cachedDictionaries[lang] = [:]
            }
            
            // Запись в кэш
            cachedDictionaries[lang]?[level] = words
            
            print("✅ Словарь уровня \(lang) \(level) загружен из JSON")
            return words
        } catch {
            print("❌ Failed to decode JSON for \(lang) \(level): \(error)")
            return []
        }
    }
    
    /// Получить все уровни, доступные в проекте (ищет JSON-файлы в Bundle)
    /// Возвращает словарь вида ["EN": ["A1","B1"], "FR": ["A2"], ...]
    func availableLevels() -> [String: [String]] {
        let fileManager = FileManager.default
        guard let resourcePath = Bundle.main.resourcePath else { return [:] }

        var result: [String: [String]] = [:]

        do {
            let files = try fileManager.contentsOfDirectory(atPath: resourcePath)

            for file in files where file.hasSuffix("_words_full.json") {
                // "EN_b1_words_full.json" -> "EN_b1"
                let baseName = file.replacingOccurrences(of: "_words_full.json", with: "")

                // Разбиваем по "_" и берём первую и вторую части
                let parts = baseName.split(separator: "_", omittingEmptySubsequences: true)
                guard parts.count >= 2 else { continue }

                let lang = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                let level = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

                // Добавляем уровень в массив для языка (без дубликатов)
                var list = result[lang] ?? []
                if !list.contains(level) {
                    list.append(level)
                    result[lang] = list
                }
            }

            // Сортируем уровни в каждом языке (например: A1, A2, B1, ...)
            for (lang, levels) in result {
                result[lang] = levels.sorted()
//                    (by: { lhs, rhs in
//                    // Попытка «умного» сравнения уровня (A1 < A2 < B1 ...)
//                    // Если не получилось распарсить — fallback на обычную лексикографическую сортировку
//                    func sortKey(_ s: String) -> (prefix: String, num: Int) {
//                        let letters = s.prefix { $0.isLetter }.uppercased()
//                        let digits = s.drop { $0.isLetter }
//                        let num = Int(digits) ?? Int.max
//                        return (letters, num)
//                    }
//                    let kl = sortKey(lhs)
//                    let kr = sortKey(rhs)
//                    if kl.prefix == kr.prefix {
//                        return kl.num < kr.num
//                    } else {
//                        return kl.prefix < kr.prefix
//                    }
//                })
            }

            return result

        } catch {
            print("❌ Failed to list available levels: \(error)")
            return [:]
        }
    }

    
    /// Очистить кэш (например, при обновлении словарей)
    func clearCache() {
        cachedDictionaries.removeAll()
        print("✅ Кэш словарей очищен")
    }
}
