//
//  GameViewModel.swift
//  Chess
//
//  Created by P Deepanshu on 01/10/24.
//

import SwiftUI
import Combine

@Observable

class GameViewModel {
    typealias ValidMoveCollection = Set<Move>
    let roster: Roster
    var game: Game
    var state: State
    var selection: Selection?
    var shouldPromptForPromotion = PassthroughSubject<Move, Never>()
    var checkhandler: CheckHandler
    var validMoveGrid = ChessGrid(repeating: ValidMoveCollection())
    var checkmateOccured = PassthroughSubject<Team, Never>()
    var moveCache: [Game: Set<Move>] = [:]
    
    init(roster: Roster, game: Game = Game.standard) {
        self.roster = roster
        self.game = game
        self.state = .working
        self.checkhandler = CheckHandler()
        self.beginNextTurn()
    }
    
    init(game: Game, roster: Roster = Roster(whitePlayer: .AI(Drawin() as AritificalIntellignence), blackPlayer: .human), selection: Selection? = nil, checkhandler: CheckHandler = CheckHandler()) {
        self.game = game
        self.roster = roster
        self.selection = selection
        self.checkhandler = checkhandler
        self.state = .working
        self.beginNextTurn()
    }
    
    
    enum State: Equatable, CustomStringConvertible {
        case awaitingInput
        case working
        case computerThinking(name: String)
        case stalemate
        case gameover(Team)
        
        var description: String {
            switch self {
            case .awaitingInput:
                return "make a Move"
            case .working:
                return "Processing"
            case .computerThinking(let name):
                return "\(name) is thinking"
            case .stalemate:
                return "Stalemate"
            case .gameover(let winner):
                return "\(winner) has won the match"
            }
        }
    }
    
    struct Selection {
        let moves: Set<Move>
        let origin: Position
        
        var grid: BooleanChessGrid {
            return BooleanChessGrid(position: moves.map {
                $0.destination
            })
        }
        
        func move(position: Position) -> Move? {
            return moves.first(where: {
                $0.destination == position
            })
        }
    }
    
    func beginNextTurn() {
        self.selection = nil
        guard checkhandler.state(team: self.game.turn, game: game) != .checkmate else {
            self.state = .gameover(self.game.turn.opponent)
            checkmateOccured.send(self.game.turn.opponent)
            return
        }
        switch roster[game.turn] {
        case .human:
            regenerateValidMoveGrid {
                self.state = .awaitingInput
            }
        case .AI(let aritificialOpponent):
            regenerateValidMoveGrid {
                self.performAIMove(opponent: aritificialOpponent) {
                    self.beginNextTurn()
                }
            }
        }
    }
    
    func regenerateValidMoveGrid(completion: @escaping () -> ()) {
        self.state = .working
        
        DispatchQueue.global(qos: .userInitiated).async {
            var validMoves: Set<Move> = []
            
            if let cachedMoves = self.moveCache[self.game] {
                validMoves = cachedMoves
            } else {
                let allMoves = self.game.allMoves(team: self.game.turn)
                let validMoves = self.checkhandler.validMoves(possibleMoves: allMoves, game: self.game)
                self.moveCache[self.game] = validMoves
            }
            self.validMoveGrid = ChessGrid(repeating: ValidMoveCollection())
                
            
            for validMove in validMoves {
                self.validMoveGrid[validMove.origin].insert(validMove)
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func performAIMove(opponent: AritificalIntellignence, callback: () -> ()) {
        self.state = .computerThinking(name: opponent.name)
        
        let minimumThinkingTime = DispatchTime.now() + DispatchTimeInterval.seconds(1)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let nextMove = opponent.nextMove(game: self.game)
            
            DispatchQueue.main.asyncAfter(deadline: minimumThinkingTime) {
                self.select(nextMove.origin)
                
                let selectionDelay = DispatchTime.now() + DispatchTimeInterval.seconds(Int(0.8))
                
                DispatchQueue.main.asyncAfter(deadline: selectionDelay) {
                    self.perform(move: nextMove)
                }
            }
        }
    }
    
    func moves(position: Position) -> Set<Move>? {
        let moves = validMoveGrid[position]
        return moves.isEmpty ? nil : moves
    }
    
    func select(_ position: Position) {
        switch selection {
        case .none:
            guard let moves = moves(position: position) else {
                return
            }
            self.selection = Selection(moves: moves, origin: position)
            
        case .some(let selection):
            if let moves = moves(position: position) {
                self.selection = Selection(moves: moves, origin: position)
            } else if let selectedMove = selection.move(position: position) {
                perform(move: selectedMove)
                return
            } else {
                self.selection = nil
            }
        }
    }
    
    func perform(move: Move) {
        game = game.performing(move)
        moveCache.removeValue(forKey: game)
        
        if case .needsPromotion = move.kind {
            guard case .human = roster[game.turn.opponent] else {
                handlePromotion(promotionType: Queen.self)
                return
            }
            shouldPromptForPromotion.send(move)
        } else {
            beginNextTurn()
        }
    }
    
    func reverseLastMove() {
        self.game = game.reversingLastMove()
        
        if case .AI(_) = roster[self.game.turn] {
            self.game = game.reversingLastMove()
        }
        moveCache.removeValue(forKey: game)
        beginNextTurn()
    }
    
    func handlePromotion(promotionType: Piece.Type) {
        let moveToPromote = game.history.last!
        assert(moveToPromote.kind == .needsPromotion)
        
        game = game.reversingLastMove()
        
        let promotionMove = Move(origin: moveToPromote.origin, destination: moveToPromote.destination, capturedPiece: moveToPromote.capturedPiece, kind: .promotion(promotionType.init(owner: game.turn)))
        
        game = game.performing(promotionMove)
        beginNextTurn()
    }
}
