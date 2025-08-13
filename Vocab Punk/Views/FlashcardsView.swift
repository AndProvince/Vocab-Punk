//
//  FlashcardsView.swift
//  Vocab Punk
//
//  Created by Андрей on 21.07.2025.
//

import SwiftUI

struct FlashcardsView: View {
    @StateObject var viewModel: FlashcardsViewModel
    @State private var showCheckmark = false
    @State private var showCross = false
    
    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var cardYOffset: CGFloat = 0  // Смещение для анимации «улетания»
    
    @State private var showLearnedHint = false
    @State private var showRepeatHint = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack(spacing: 6) {
                    Image(systemName: "book.fill")
                        .font(.title2)
                    Text("Уровень: \(viewModel.level)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(.top)
                
                Spacer()
                
                // Подсказка "Выучил"
                if showLearnedHint {
                    hintView(title: "Выучено", systemIcon: "chevron.up")
                        .offset(y: -20)
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(30)
                }
                
                if showCross {
                    overlayIcon("clock.arrow.circlepath", color: .blue)
                        .zIndex(20)
                }
                
                // Основная карточка
                if let card = viewModel.currentCard {
                    FlipCardView(card: card, rotationAngle: rotationAngle, level: viewModel.level)
                        .frame(height: 400)
                        .padding(.horizontal)
                        .offset(y: cardYOffset + dragOffset.height)
                        .zIndex(10)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    handleDragChanged(value)
                                }
                                .onEnded { value in
                                    handleDragEnded(value)
                                }
                        )
                } else {
                    Text("Нет слов")
                        .font(.title2)
                        .zIndex(10)
                }
                
                if showCheckmark {
                    overlayIcon("checkmark.circle.fill", color: .green)
                        .zIndex(20)
                }
                
                // Подсказка "Надо повторить"
                if showRepeatHint {
                    hintView(title: "Повторить", systemIcon: "chevron.down")
                        .offset(y: 20)
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(30)
                }
                
                Spacer()
                
                // Стопка карт снизу
                cardStack(level: viewModel.level)
                    .padding(.bottom, 20)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeInOut, value: showCheckmark)
        .animation(.easeInOut, value: showCross)
        .animation(.easeInOut, value: showLearnedHint)
        .animation(.easeInOut, value: showRepeatHint)
    }

    // MARK: - Drag Handlers
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        dragOffset = value.translation
        
        let horizontal = value.translation.width
        let vertical = value.translation.height
        
        // Показываем подсказки при достаточном смещении
        showLearnedHint = vertical < -20
        showRepeatHint = vertical > 20
        
        // Проверяем направление для переворота
        let canFlip: Bool = (!viewModel.isFlipped && horizontal < 0) || (viewModel.isFlipped && horizontal > 0)
        
        if abs(horizontal) > abs(vertical) && canFlip {
            let progress = Double(horizontal) / 2
            rotationAngle = (viewModel.isFlipped ? 180 : 0) - progress
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let horizontal = value.translation.width
        let vertical = value.translation.height
        
        // Скрываем подсказки
        showLearnedHint = false
        showRepeatHint = false
        
        let canFlip: Bool = (!viewModel.isFlipped && horizontal < 0) || (viewModel.isFlipped && horizontal > 0)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if abs(horizontal) > 80 && abs(horizontal) > abs(vertical) && canFlip {
                // Переворот
                viewModel.flipCard()
                rotationAngle = viewModel.isFlipped ? 180 : 0
                
            } else if vertical < -80 {
                // Свайп вверх -> следующая карточка
                withAnimation {
                    cardYOffset = -UIScreen.main.bounds.height
                    showCheckmark = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cardYOffset = UIScreen.main.bounds.height
                    withAnimation {
                        showCheckmark = false
                        viewModel.nextCard()
                        if viewModel.isFlipped { viewModel.flipCard() }
                        cardYOffset = 0
                        rotationAngle = 0
                    }
                }
                
            } else if vertical > 80 {
                // Свайп вниз -> предыдущая карточка
                withAnimation(.easeInOut(duration: 0.5)) {
                    cardYOffset = UIScreen.main.bounds.height
                    showCross = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showCross = false
                        viewModel.nextCard()
                        if viewModel.isFlipped { viewModel.flipCard() }
                        cardYOffset = 0
                        rotationAngle = 0
                    }
                }
                
            } else {
                // Возврат к текущей стороне
                rotationAngle = viewModel.isFlipped ? 180 : 0
            }
            
            dragOffset = .zero
        }
    }
    
    // MARK: - UI Elements
    
    private func overlayIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 100))
            .foregroundColor(color)
            .transition(.scale)
    }
    
    private func hintView(title: String, systemIcon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemIcon)
                .font(.headline)
            Text(title)
                .font(.headline)
        }
        .padding(8)
        .cornerRadius(8)
        .foregroundColor(.white)
        .scaleEffect(1.05)
        .opacity(0.9)
    }
}
