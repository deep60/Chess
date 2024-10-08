//
//  Bishop.swift
//  Chess
//
//  Created by P Deepanshu on 26/09/24.
//

import Foundation

class Bishop: Piece {
    required init(owner: Team) {
        super.init(owner: owner)
    }
    
    override var value: Int {
        return 4
    }
    
    override func threatenedPositions(position: Position, game: Game) -> BooleanChessGrid {
        let directedPos = DirectedPos(position: position, perspective: owner)
        let frontLeftMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.diagonalLeftFrontSpaces.map({$0.position}), board: game.board)
        let frontRightMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.diagonalRightFrontSpaces.map({$0.position}), board: game.board)
        let backLeftMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.diagonalLeftBackSpaces.map({$0.position}), board: game.board)
        let backRightMoves = Position.pathConsideringCollisions(team: owner, path: directedPos.diagonalRightBackSpaces.map({$0.position}), board: game.board)
        let allMoves = frontLeftMoves + frontRightMoves + backLeftMoves + backRightMoves
        
        return BooleanChessGrid(position: allMoves)
    }
    
    override func possibleMoves(position: Position, game: Game) -> Set<Move> {
        return threatenedPositions(position: position, game: game).toMoves(origin: position, board: game.board)
    }
}
