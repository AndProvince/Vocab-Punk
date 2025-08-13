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
