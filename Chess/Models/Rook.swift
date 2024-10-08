//
//  Rook.swift
//  Chess
//
//  Created by P Deepanshu on 26/09/24.
//

import Foundation

class Rook: Piece {
    required init(owner: Team) {
        super.init(owner: owner)
    }
    
    override var value: Int {
        return 5
    }
    
    override func threatenedPositions(position: Position, game: Game) -> BooleanChessGrid {
        let directedPos = DirectedPos(position: position, perspective: owner)
        let frontMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.frontSpaces.map({$0.position}), board: game.board)
        let backMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.backSpaces.map({$0.position}), board: game.board)
        let leftMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.leftSpaces.map({$0.position}), board: game.board)
        let rightMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.rightSpaces.map({$0.position}), board: game.board)
        
        let allMoves = frontMoves + backMoves + leftMoves + rightMoves
        
        return BooleanChessGrid(position: allMoves)
    }
    
    override func possibleMoves(position: Position, game: Game) -> Set<Move> {
        return threatenedPositions(position: position, game: game).toMoves(origin: position, board: game.board)
    }
}
