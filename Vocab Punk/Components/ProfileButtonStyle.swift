//
//  ProfileButtonStyle.swift
//  Vocab Punk
//
//  Created by Андрей on 14.08.2025.
//

import SwiftUI

struct ProfileButtonStyle: ViewModifier {
    var backgroundColor: Color
    var foregroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
