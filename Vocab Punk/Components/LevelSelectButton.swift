//
//  LevelSelectButton.swift
//  Vocab Punk
//
//  Created by Андрей on 25.07.2025.
//

import SwiftUI

struct LevelSelectButton: View {
    let level: String
    let action: () -> Void

    var body: some View {
        let colors = LevelColorManager.shared.scheme(for: level).buttonColors
        
        return Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Уровень")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(level)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(height: 70)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: colors.first?.opacity(0.3) ?? .black, radius: 5, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
