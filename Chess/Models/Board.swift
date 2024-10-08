//
//  Board.swift
//  Chess
//
//  Created by P Deepanshu on 25/09/24.
//

import SwiftUI

typealias Board = ChessGrid<Piece?>

extension Board {
    static let standard: Board = {
        let pieces: [Piece?] = [
            Rook(owner: .black),
            Knight(owner: .black),
            Bishop(owner: .black),
            Queen(owner: .black),
            King(owner: .black),
            Bishop(owner: .black),
            Knight(owner: .black),
            Rook(owner: .black),
            
            Pawn(owner: .black),
            Pawn(owner: .black),
            Pawn(owner: .black),
            Pawn(owner: .black),
            Pawn(owner: .black),
            Pawn(owner: .black),
            Pawn(owner: .black),
            Pawn(owner: .black),
            
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil,
            
            Pawn(owner: .white),
            Pawn(owner: .white),
            Pawn(owner: .white),
            Pawn(owner: .white),
            Pawn(owner: .white),
            Pawn(owner: .white),
            Pawn(owner: .white),
            Pawn(owner: .white),
            
            Rook(owner: .white),
            Knight(owner: .white),
            Bishop(owner: .white),
            Queen(owner: .white),
            King(owner: .white),
            Bishop(owner: .white),
            Knight(owner: .white),
            Rook(owner: .white),
        ]
        
        return ChessGrid(array: pieces)
    }()
    
    static let colors: ChessGrid<Color> = {
        let colors: [Color] = zip(standard.indices, standard)
            .map { position, piece in
                return (position.row.rawValue + position.rank.rawValue).isMultiple(of: 2) ? .green.opacity(0.5) : .gray.opacity(0.1)
            }
        return ChessGrid<Color>(array: colors)
    }()
}
