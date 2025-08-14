//
//  Vocab_PunkApp.swift
//  Vocab Punk
//
//  Created by Андрей on 21.07.2025.
//

import SwiftUI

@main
struct Vocab_PunkApp: App {
    @State private var showLaunchScreen = true
    
    init() {
        // Читаем значение или используем дефолт
//        let host = UserDefaults.standard.string(forKey: "dictionaryHost") ?? "http://127.0.0.1:3000"
//        DictionaryUpdateService.shared.configure(host: host)
        
        DictionaryUpdateScheduler.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchView(isActive: $showLaunchScreen)
            } else {
                FlashcardsSetsView()
            }
        }
    }
}
