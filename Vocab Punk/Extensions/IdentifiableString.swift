//
//  IdentifiableString.swift
//  Vocab Punk
//
//  Created by Андрей on 25.07.2025.
//

import Foundation

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}
