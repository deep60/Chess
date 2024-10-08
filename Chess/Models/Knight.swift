//
//  Knight.swift
//  Chess
//
//  Created by P Deepanshu on 27/09/24.
//

import Foundation

class Knight: Piece {
    required init(owner: Team) {
        super.init(owner: owner)
    }
    
    override var value: Int {
        return 3
    }
    
    override func threatenedPositions(position: Position, game: Game) -> BooleanChessGrid {
        let directedPos = DirectedPos(position: position, perspective: owner)
        
        let upperLeftA = directedPos.left?.front?.front
        let upperLeftB = directedPos.left?.left?.front
        let upperRightA = directedPos.right?.right?.front
        let upperRightB = directedPos.right?.front?.front
        let lowerLeftA = directedPos.left?.back?.back
        let lowerLeftB = directedPos.left?.left?.back
        let lowerRightA = directedPos.right?.right?.back
        let lowerRightB = directedPos.right?.back?.back
        
        let allMoves = [upperLeftA, upperLeftB, upperRightA, upperRightB, lowerLeftA, lowerLeftB, lowerRightA, lowerRightB]
            .compactMap {
                $0?.position
            }
            .filter {
                switch game.board[$0] {
                case .some(let collidingPiece):
                    return collidingPiece.owner != self.owner
                case .none:
                    return true
                }
            }
        return BooleanChessGrid(position: allMoves)
    }
    
    override func possibleMoves(position: Position, game: Game) -> Set<Move> {
        return threatenedPositions(position: position, game: game).toMoves(origin: position, board: game.board)
    }
}
