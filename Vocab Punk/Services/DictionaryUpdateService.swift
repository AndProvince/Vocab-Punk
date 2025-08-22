//
//  DictionaryUpdateService.swift
//  Vocab Punk
//
//  Created by Андрей on 13.08.2025.
//

import Foundation

enum DictionaryUpdateError: Error {
    case invalidManifest
    case downloadFailed(URL)
    case persistFailed(URL)
}

final class DictionaryUpdateService: ObservableObject {
    static let shared = DictionaryUpdateService()
    
    // MARK: - Конфигурация
    private(set) var hostURL: String
    private(set) var manifestURL: URL
    
    // MARK: - Версия
    private let localVersionKey = "dictionaryVersion"

    @Published private(set) var localVersion: String? = nil
    
    // MARK: - Пути хранения
    private var dictionariesDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("dictionaries", isDirectory: true)
    }

    private var tempDir: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("dictionaries_tmp", isDirectory: true)
    }
    
    private init() {
        hostURL = "https://andprovince.pythonanywhere.com"   //  "http://127.0.0.1:3000" 
        manifestURL = URL(string: "\(hostURL)/version")!

        loadLocalVersion()
    }
    
    func configure(host: String) {
        self.hostURL = host
        self.manifestURL = URL(string: "\(host)/version")!
    }
    
    private func loadLocalVersion() {
        localVersion = UserDefaults.standard.string(forKey: localVersionKey)
    }
    
    private func saveLocalVersion(_ version: String) {
        DispatchQueue.main.async {
            self.localVersion = version
            UserDefaults.standard.set(version, forKey: self.localVersionKey)
        }
    }

    // MARK: - Публичный API
    @discardableResult
    func checkAndUpdateIfNeeded() async -> Bool {
        do {
            let manifest = try await fetchManifest()
            guard manifest.version != localVersion else {
                // актуально
                print("Локальные словари соответствуют серверу")
                return false
            }
            
            print("Обновление словарей")
            try await downloadAll(from: manifest)
            try replaceLocalDictionariesWithTemp()
            DictionaryManager.shared.clearCache() // чистим in-memory
            saveLocalVersion(manifest.version)

            NotificationCenter.default.post(name: .dictionariesDidUpdate, object: nil)
            return true
        } catch {
            print("❌ Dictionary update failed: \(error)")
            return false
        }
    }

    // MARK: - Запрос манифеста
    private func fetchManifest() async throws -> DictionaryManifest {
        let (data, _) = try await URLSession.shared.data(from: manifestURL)
        guard let manifest = try? JSONDecoder().decode(DictionaryManifest.self, from: data) else {
            throw DictionaryUpdateError.invalidManifest
        }
        return manifest
    }

    // MARK: - Загрузка всех файлов
    private func downloadAll(from manifest: DictionaryManifest) async throws {
        // Подготовим temp dir начисто
        try? FileManager.default.removeItem(at: tempDir)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        try await withThrowingTaskGroup(of: Void.self) { group in
            for file in manifest.files {
                group.addTask { [url = URL(string: "\(self.hostURL)\(file.url)")!, tempDir = self.tempDir, lang = file.language, level = file.level] in
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let langDir = tempDir.appendingPathComponent(lang, isDirectory: true)
                    try FileManager.default.createDirectory(at: langDir, withIntermediateDirectories: true)
                    let dest = langDir.appendingPathComponent("\(level.uppercased())_words_full.json")
                    do {
                        try data.write(to: dest, options: .atomic)
                    } catch {
                        throw DictionaryUpdateError.persistFailed(dest)
                    }
                }
            }
            try await group.waitForAll()
        }
    }

    // MARK: - Атомарная замена каталога словарей
    private func replaceLocalDictionariesWithTemp() throws {
        // Подготовим основную папку
        try FileManager.default.createDirectory(at: dictionariesDir, withIntermediateDirectories: true)

        // Удалим старые файлы
        let existing = (try? FileManager.default.contentsOfDirectory(at: dictionariesDir, includingPropertiesForKeys: nil)) ?? []
        for url in existing {
            try? FileManager.default.removeItem(at: url)
        }

        // Перенесем всё из tempDir в dictionariesDir
        let tempContent = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        for folder in tempContent {
            let target = dictionariesDir.appendingPathComponent(folder.lastPathComponent, isDirectory: true)
            try FileManager.default.moveItem(at: folder, to: target)
        }
        // Удалим temp
        try? FileManager.default.removeItem(at: tempDir)
    }
}
