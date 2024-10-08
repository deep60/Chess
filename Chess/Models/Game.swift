//
//  Game.swift
//  Chess
//
//  Created by P Deepanshu on 25/09/24.
//

import Foundation

struct Game: Equatable {
    let board: Board
    let history: [Move]
    let turn: Team
    
    static let standard = Game(board: .standard)
    static let validator = CheckHandler()
    
    init(board: Board) {
        self = Game(board: board, history: [], turn: .white)
    }
    
    init(board: Board, history: [Move] = [], turn: Team = .white) {
        self.board = board
        self.history = history
        self.turn = turn
    }
    
    func performing(_ move: Move) -> Game {
        var newBoard = board
        var newHistory = history
        var newTurn = turn.opponent
        
        let pieceToMove = board[move.origin]!
        newBoard[move.origin] = nil
        newBoard[move.destination] = pieceToMove
        
        switch move.kind {
        case .standard, .needsPromotion:
            break
        case .enPassant:
            let capturedPosition = DirectedPos(position: move.destination, perspective: turn)
                .back!
                .position
            newBoard[capturedPosition] = nil
            
        case .castle:
            let isKingsideCastle = move.origin.rank.rawValue < move.destination.rank.rawValue
            let newRookRank = Rank(rawValue: isKingsideCastle ? move.destination.rank.rawValue - 1 : move.destination.rank.rawValue + 1)!
            let rookDestination = Position(rank: newRookRank, row: move.destination.row)
            let rookOrigin = Position(rank: isKingsideCastle ? .H : .A, row: pieceToMove.owner == .white ? .one : .eight)
            
            assert(newBoard[rookOrigin] is Rook)
            let rook = board[rookOrigin]!
            newBoard[rookOrigin] = nil
            newBoard[rookDestination] = rook
        case .promotion(let promotionPiece):
            newBoard[move.destination] = promotionPiece
        }
        newHistory.append(move)
        return Game(board: newBoard, history: newHistory, turn: newTurn)
    }
    
    func reversingLastMove() -> Game {
        var newBoard = board
        var newHistory = history
        var newTurn = turn.opponent
        
        guard let move = newHistory.popLast() else {
            return self
        }
        
        switch move.kind {
        case .standard, .needsPromotion:
            let pieceToReverse = newBoard[move.destination]!
            newBoard[move.origin] = pieceToReverse
            newBoard[move.destination] = move.capturedPiece
        case .castle:
            let pieceToReverse = newBoard[move.destination]!
            newBoard[move.origin] = pieceToReverse
            newBoard[move.destination] = nil
            
            let isKingsideCastle = move.origin.rank.rawValue < move.destination.rank.rawValue
            let rookToReverseRank = Rank(rawValue: isKingsideCastle ? move.destination.rank.rawValue - 1 : move.destination.rank.rawValue + 1)!
            let rookCurrentPosition = Position(rank: rookToReverseRank, row: move.destination.row)
            let rookDestination = Position(rank: isKingsideCastle ? .H : .A, row: pieceToReverse.owner == .white ? .one : .eight)
            
            let rook = board[rookCurrentPosition]!
            newBoard[rookCurrentPosition] = nil
            newBoard[rookDestination] = rook
            
            
        case .enPassant:
            let pieceToReverse = newBoard[move.destination]!
            newBoard[move.origin] = pieceToReverse
            newBoard[move.destination] = nil
            
            let capturedPosition = DirectedPos(position: move.destination, perspective: turn.opponent).back!.position
            newBoard[capturedPosition] = move.capturedPiece
        case.promotion(_):
            let pieceToReverse = Pawn(owner: turn.opponent)
            newBoard[move.origin] = pieceToReverse
            newBoard[move.destination] = move.capturedPiece
        }
        
        return Game(board: newBoard, history: newHistory, turn: newTurn)
    }
    
    func moves(position: Position) -> Set<Move>? {
        guard let piece = board[position] else {
            return nil
        }
        
        return piece.possibleMoves(position: position, game: self)
    }
    
    func allMoves(team: Team) -> Set<Move> {
        return board.indices
            .reduce(Set<Move>()) { (nextPartialResult, position) -> Set<Move> in
                guard let piece = board[position], piece.owner == team else {
                    return nextPartialResult
                }
                
                return nextPartialResult.union(piece.possibleMoves(position: position, game: self))
            }
    }
    
    func positionsThreatened(team: Team) -> BooleanChessGrid {
        return zip(board.indices, board).compactMap { position, piece in
            guard piece?.owner == team else {
                return nil
            }
            return piece?.threatenedPositions(position: position, game: self)
        }
        .reduce(BooleanChessGrid.false) { (nextPartialResult, moves) -> BooleanChessGrid in
            nextPartialResult.union(moves)
        }
    }
    
    func kingPosition(team: Team) -> Position {
        return zip(board.indices, board)
            .first { position, piece in
                piece is King && piece?.owner == team
            }!.0
    }
    
    func currentMoves() -> Set<Move> {
        return Game.validator.validMoves(possibleMoves: allMoves(team: turn), game: self)
    }
}

extension Game: Hashable {}
