//
//  LevelProgressCardView.swift
//  Vocab Punk
//
//  Created by Андрей on 25.07.2025.
//

import SwiftUI

struct LevelProgressCardView: View {
    let selectedLanguage: String
    let level: String
    let email: String
    let progress: Double   // от 0 до 100
    
    private var totalWords: Int {
        DictionaryManager.shared.loadDictionary(lang: selectedLanguage, level: level).count
    }
    
    private var learnedWords: Int {
        let progressData = ProgressManager.shared.loadProgress(for: email)
        return DictionaryManager.shared.loadDictionary(lang: selectedLanguage, level: level).filter { card in
            progressData[card.id]?.memoryScore ?? 0 >= 80
        }.count
    }
    
    private var inProgressWords: Int {
        let progressData = ProgressManager.shared.loadProgress(for: email)
        return DictionaryManager.shared.loadDictionary(lang: selectedLanguage, level: level).filter { card in
            let score = progressData[card.id]?.memoryScore ?? 0
            return score > 0 && score < 80
        }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            Text("Уровень \(level)")
                .font(.headline)
            
            // Прогресс
            ProgressView(value: progress, total: 100)
                .tint(progress >= 80 ? .green : .blue)
                .padding(.vertical, 4)
            
            Text("Прогресс: \(Int(progress))%")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Статистика
            HStack(spacing: 20) {
                StatColumn(title: "Всего слов:", value: totalWords, color: .secondary)
                StatColumn(title: "Изучено:", value: learnedWords, color: .green)
                StatColumn(title: "В процессе:", value: inProgressWords, color: .orange)
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// Вспомогательная вью для отображения одной колонки статистики
private struct StatColumn: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(color)
            Text("\(value)")
                .font(.caption)
                .foregroundColor(color)
        }
    }
}
