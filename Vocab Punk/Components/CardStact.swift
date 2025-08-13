//
//  CardStact.swift
//  Vocab Punk
//
//  Created by Андрей on 23.07.2025.
//

import SwiftUI

struct cardStack: View {
    var level: String 
    
    var body: some View {
        let scheme = LevelColorManager.shared.scheme(for: level)
        
        VStack(spacing: -85) {
            ForEach((0..<7).reversed(), id: \.self) { index in
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: scheme.frontColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1) // кромка
                    )
                    .frame(height: 100)
                    .scaleEffect(1 - CGFloat(index) * 0.03) // каждая следующая чуть меньше
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
            }
        }
        .frame(maxHeight: 80)
        .padding(.top, 20)
    }
}
