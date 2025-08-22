//
//  HashString.swift
//  Vocab Punk
//
//  Created by Андрей on 22.08.2025.
//

import Foundation
import CryptoKit

extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
