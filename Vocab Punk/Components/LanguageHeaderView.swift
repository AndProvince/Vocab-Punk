//
//  LanguageHeader.swift
//  Vocab Punk
//
//  Created by Андрей on 13.08.2025.
//

import SwiftUI

struct LanguageHeaderView: View {
    var languageCode: String

    var body: some View {
        HStack(spacing: 8) {
            Image(LanguagesData.flags[languageCode] ?? "flag")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .shadow(radius: 1, y: 1)

            Text(LanguagesData.names[languageCode] ?? languageCode)
                .font(.headline)
                .foregroundColor(.primary)
            
//            Image(systemName: "chevron.down")
//                .font(.caption)
//                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
