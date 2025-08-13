//
//  CardContent.swift
//  Vocab Punk
//
//  Created by Андрей on 22.07.2025.
//

import SwiftUI
import Foundation

enum CornerSide {
    case left, right
}

struct CardContent: View {
    let title: String
    let ipa: String
    let translit: String
    let gradient: LinearGradient
    let cornerSide: CornerSide
    let oppositeGradient: LinearGradient
    
    var body: some View {
        ZStack(alignment: cornerSide == .left ? .topTrailing : .topLeading) {
            // Основной контент карточки
            VStack(spacing: 10) {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                Text("[\(ipa)]")
                    .font(.title2)
                Text(translit)
                    .font(.title3)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(gradient)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .shadow(radius: 6)
            
            // Закладка
            bookmark
                .frame(width: 24, height: 60)
                .offset(x: cornerSide == .left ? -12 : 12, y: 0)
        }
    }
    
    private var bookmark: some View {
        ZStack {
            oppositeGradient
                .clipShape(BookmarkShape())
                .overlay(
                    BookmarkShape()
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
                .shadow(radius: 2)
        }
    }
}

private struct BookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Прямоугольник с треугольным вырезом снизу
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 10))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 10))
        path.closeSubpath()
        return path
    }
}

