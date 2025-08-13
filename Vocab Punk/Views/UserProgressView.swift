//
//  UserProgressView.swift
//  Vocab Punk
//
//  Created by Андрей on 24.07.2025.
//

import SwiftUI

struct UserProgressView: View {
    @ObservedObject var flashcardsVM: FlashcardsViewModel  // Используем существующую модель
    
    var body: some View {
        VStack {
            LanguageHeaderView(languageCode: flashcardsVM.lang)
            
            Text("Прогресс — \(flashcardsVM.level)")
                .font(.subheadline)
            
            List {
                ForEach(flashcardsVM.cards, id: \.id) { card in
                    HStack {
                        Text(card.englishWord)
                            .font(.headline)
                        if let record = flashcardsVM.progress[card.id] {
                            VStack(alignment: .leading) {
                                ProgressView(value: Float(record.memoryScore) / 100.0)
                                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor(for: record.memoryScore)))
                                Text("Запоминание: \(record.memoryScore)%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if record.memoryScore >= 80 {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func progressColor(for score: Int) -> Color {
        switch score {
        case 80...: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
}
