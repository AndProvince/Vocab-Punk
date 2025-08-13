//
//  LaunchView.swift
//  Vocab Punk
//
//  Created by Андрей on 29.07.2025.
//

import SwiftUI

struct LaunchView: View {
    @Binding var isActive: Bool
    @State private var offsetY: CGFloat = 50
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .offset(y: offsetY)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            offsetY = 0
                            opacity = 1.0
                        }
                    }
                
                Text("Vocab Punk")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0).delay(0.2)) {
                            opacity = 1.0
                        }
                    }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { isActive = false }
            }
        }
    }
}
