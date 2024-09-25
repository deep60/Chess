//
//  Move.swift
//  Chess
//
//  Created by P Deepanshu on 24/09/24.
//

import Foundation

struct Move: Hashable {
    let origin: Position
    let destination: Position
    let capturedPiece: Piece?
    let kind: Kind
    
    init(origin: Position, destination: Position, capturedPiece: Piece?, kind: Kind) {
        self.origin = origin
        self.destination = destination
        self.capturedPiece = capturedPiece
        self.kind = kind
    }
}

extension Move: CustomStringConvertible {
    var description: String {
        switch kind {
        case .standard:
            return "\(origin) -> \(destination)"
        case .castle:
            return "\(origin) -> \(destination) Castle"
        case .enPassant:
            return "\(origin) -> \(destination) En Passant"
        case .needsPromotion:
            return "\(origin) -> \(destination) Needs Promotion"
        case .promotion(_):
            return "\(origin) -> \(destination) Promotion"
        }
    }
}
