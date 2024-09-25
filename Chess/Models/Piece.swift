//
//  Piece.swift
//  Chess
//
//  Created by P Deepanshu on 24/09/24.
//

import SwiftUI

class Piece {
    var owner: Team
    
    required init(owner: Team) {
        self.owner = owner
    }
    
    var value: Int {
        return 0
    }
    
    var image: Image {
        let color = owner.description
        let piece = String(describing: type(of: self)).lowercased()
        return Image("\(piece) \(color)", bundle: Bundle(for: type(of: self)))
    }
}

extension Piece: Equatable {
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        guard lhs.owner == rhs.owner && type(of: lhs) == type(of: rhs) else {
            return false
        }
        
        return true
    }
}

extension Piece: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(owner)
        hasher.combine(String(describing: type(of: self)))
    }
}
