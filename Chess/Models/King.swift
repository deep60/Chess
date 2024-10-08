//
//  King.swift
//  Chess
//
//  Created by P Deepanshu on 28/09/24.
//

import Foundation

class King: Piece {
    required init(owner: Team) {
        super.init(owner: owner)
    }
    
    override var value: Int {
        return 999
    }
    
    func standardMoveGrid(position: Position, game: Game) -> BooleanChessGrid {
        let directedPos = DirectedPos(position: position, perspective: owner)
        
        let frontMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.front?.position].compactMap({
            $0
        }), board: game.board)
        let backMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.back?.position].compactMap({
            $0
        }), board: game.board)
        let leftMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.left?.position].compactMap({
            $0
        }), board: game.board)
        let rightMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.right?.position].compactMap({
            $0
        }), board: game.board)
        let frontLeftMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.diagonalLeftFront?.position].compactMap({
            $0
        }), board: game.board)
        let frontRightMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.diagonalRightFront?.position].compactMap({
            $0
        }), board: game.board)
        let backLeftMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.diagonalLeftBack?.position].compactMap({
            $0
        }), board: game.board)
        let backRightMove = Position.pathConsideringCollisions(team: owner, path: [directedPos.diagonalRightBack?.position].compactMap({
            $0
        }), board: game.board)
        
        let allMoves = frontMove + backMove + leftMove + rightMove + frontLeftMove + frontRightMove + backLeftMove + backRightMove
        return BooleanChessGrid(position: allMoves)
    }
    
    override func threatenedPositions(position: Position, game: Game) -> BooleanChessGrid {
        return standardMoveGrid(position: position, game: game)
    }
    
    override func possibleMoves(position: Position, game: Game) -> Set<Move> {
        let standardMoves = standardMoveGrid(position: position, game: game).toMoves(origin: position, board: game.board)
        
        let castleMoves: Set<Move> = {
            let startingPosition = owner == .white ? Position(rank: .E, row: .one) : Position(rank: .E, row: .eight)
            
            let movesFromStartingPosition = game.history.filter {
                $0.origin == startingPosition
            }
            
            guard position == startingPosition, movesFromStartingPosition.count == 0 else {
                return Set()
            }
            let directedPos = DirectedPos(position: position, perspective: owner)
            
            let queensideCastle: Move? = {
                let rookPosition = self.owner == .white ? Position(rank: .E, row: .one) : Position(rank: .A, row: .eight)
                
                let movesFromRookPosition = game.history.filter {
                    $0.origin == rookPosition
                }
                
                guard let _ = game.board[rookPosition] as? Rook, movesFromRookPosition.count == 0 else {
                    return nil
                }
                
                let spacesThatAreRequiredToBeEmpty = (owner == .white ? directedPos.leftSpaces : directedPos.rightSpaces).dropLast()
                    .map {
                        $0.position
                    }
                
                for space in spacesThatAreRequiredToBeEmpty {
                    guard game.board[space] == nil else {
                        return nil
                    }
                }
                
                let spacesThatAreRequiredToBeUnthreatened = spacesThatAreRequiredToBeEmpty.dropLast()
                let positionsThreatenedByOpponent = game.positionsThreatened(team: owner.opponent)
                
                for space in spacesThatAreRequiredToBeUnthreatened {
                    guard !positionsThreatenedByOpponent[space] else {
                        return nil
                    }
                }
                
                let destination: Position! = (owner == .white ? directedPos.left?.left : directedPos.right?.right)?.position
                
                guard !positionsThreatenedByOpponent[position],
                        !positionsThreatenedByOpponent[destination] else {
                    return nil
                }
                return Move(origin: position, destination: destination, capturedPiece: nil, kind: .castle)
            }()
            
            let kingsideCastle: Move? = {
                let rookPosition = self.owner == .white ? Position(rank: .H, row: .one) : Position(rank: .H, row: .eight)
                
                let movesFromRookPosition = game.history.filter {
                    $0.origin == rookPosition
                }
                guard let _ = game.board[rookPosition] as? Rook, movesFromRookPosition.count == 0 else {
                    return nil
                }
                let spacesThatAreRequiredToBeEmptyAndUnthreatened = (owner == .white ? directedPos.rightSpaces : directedPos.leftSpaces).dropLast()
                    .map {
                        $0.position
                    }
                
                for space in spacesThatAreRequiredToBeEmptyAndUnthreatened {
                    guard game.board[space] == nil else {
                        return nil
                    }
                }
                let positionsThreatenedByOpponent = game.positionsThreatened(team: owner.opponent)
                
                for space in spacesThatAreRequiredToBeEmptyAndUnthreatened {
                    guard !positionsThreatenedByOpponent[space] else {
                        return nil
                    }
                }
                
                let destination: Position! = (owner == .white ? directedPos.right?.right : directedPos.left?.left)?.position
                
                guard !positionsThreatenedByOpponent[position],
                      !positionsThreatenedByOpponent[destination] else {
                    return nil
                }
                return Move(origin: position, destination: destination, capturedPiece: nil, kind: .castle)
            }()
            
            return [queensideCastle, kingsideCastle]
                .compactMap {
                    $0
                }.toSet()
        }()
        
        return standardMoves.union(castleMoves)
    }
}
