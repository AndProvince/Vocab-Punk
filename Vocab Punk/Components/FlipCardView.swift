//
//  FlipCardView.swift
//  Vocab Punk
//
//  Created by Андрей on 21.07.2025.
//

import SwiftUI

struct FlipCardView: View {
    let card: WordCard
    var rotationAngle: Double
    var level: String   // передаём уровень
    
    var body: some View {
        let scheme = LevelColorManager.shared.scheme(for: level)
        
        ZStack {
            frontSide(scheme: scheme)
                .opacity(showFront ? 1 : 0)
                .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: -1, z: 0))
            
            backSide(scheme: scheme)
                .opacity(showFront ? 0 : 1)
                .rotation3DEffect(.degrees(rotationAngle + 180), axis: (x: 0, y: -1, z: 0))
        }
    }
    
    private var showFront: Bool {
        let normalized = rotationAngle.truncatingRemainder(dividingBy: 360)
        return normalized < 90 || normalized > 270
    }
    
    private func frontSide(scheme: LevelColorScheme) -> some View {
        CardContent(
            title: card.englishWord,
            ipa: card.englishIPA,
            translit: card.englishIPAru,
            gradient: LinearGradient(colors: scheme.frontColors, startPoint: .topLeading, endPoint: .bottomTrailing),
            cornerSide: .left,
            oppositeGradient: LinearGradient(colors: scheme.backColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
    
    private func backSide(scheme: LevelColorScheme) -> some View {
        CardContent(
            title: card.russianWord,
            ipa: card.russianIPA,
            translit: card.russianIPAen,
            gradient: LinearGradient(colors: scheme.backColors, startPoint: .topLeading, endPoint: .bottomTrailing),
            cornerSide: .right,
            oppositeGradient: LinearGradient(colors: scheme.frontColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}
