//
//  Drawin.swift
//  Chess
//
//  Created by P Deepanshu on 30/09/24.
//

import Foundation

class Drawin: AritificalIntellignence {
    var name: String {
        "Drawin"
    }
    
    func nextMove(game: Game) -> Move {
        let moves = game.currentMoves()
        
        let analyses = moves.map { move in
            analysis(move: move, team: game.turn, game: game)
        }
            .sorted(by: {$0.isObjectivelybetter(otherAnalysis: $1)})
        return analyses.first!.move
    }
    
    init() {
        
    }
    
    struct ScenarioAnalysis {
        let mostValuablePieceThreatenedByOpponent: Piece?
        let mostValueablePieceThreatenedByUs: Piece?
        
        var opponentThreatValue: Int {
            return mostValuablePieceThreatenedByOpponent?.value ?? 0
        }
        
        var ourThreatValue: Int {
            return mostValueablePieceThreatenedByUs?.value ?? 0
        }
        
        var threatScore: Int {
            return ourThreatValue - opponentThreatValue
        }
    }
    
    struct MoveAnalysis {
        let capturedPiece: Piece?
        let oldScenario: ScenarioAnalysis
        let newScenario: ScenarioAnalysis
        let move: Move
        
        var exchangeRatio: Int {
            (capturedPiece?.value ?? 0) - newScenario.opponentThreatValue
        }
        
        var threatScore: Int {
            return newScenario.threatScore - oldScenario.threatScore
        }
        
        func isObjectivelybetter(otherAnalysis: MoveAnalysis) -> Bool {
            guard self.exchangeRatio == otherAnalysis.exchangeRatio else {
                return self.exchangeRatio > otherAnalysis.exchangeRatio
            }
            
            return self.threatScore > otherAnalysis.threatScore
        }
    }
    
    func analysis(move: Move, team: Team, game: Game) -> MoveAnalysis {
        let currentMostValuablePieceThreatenedByOpponent = mostValuablePieceThreatened(team: team.opponent, game: game)
        let currentMostValuablePieceThreatenedByUs = mostValuablePieceThreatened(team: team, game: game)
        let oldScenarioAnalysis = ScenarioAnalysis(mostValuablePieceThreatenedByOpponent: currentMostValuablePieceThreatenedByOpponent, mostValueablePieceThreatenedByUs: currentMostValuablePieceThreatenedByUs)
        
        let newScenario = game.performing(move)
        let newMostValuablePieceThreatenedByOpponent = mostValuablePieceThreatened(team: team.opponent, game: newScenario)
        let newMostValuablePieceThreatenedByUs = mostValuablePieceThreatened(team: team, game: newScenario)
        
        let newScenarioAnalysis = ScenarioAnalysis(mostValuablePieceThreatenedByOpponent: newMostValuablePieceThreatenedByOpponent, mostValueablePieceThreatenedByUs: newMostValuablePieceThreatenedByUs)
        
        return MoveAnalysis(capturedPiece: move.capturedPiece, oldScenario: oldScenarioAnalysis, newScenario: newScenarioAnalysis, move: move)
        
    }
    
    func mostValuablePieceThreatened(team: Team, game: Game) -> Piece? {
        let threatenedPositions = game.positionsThreatened(team: team)
        return zip(threatenedPositions.indices, threatenedPositions)
            .filter { position, isThreatened in
                isThreatened
            }
            .compactMap { position, isThreatened in
                guard let piece = game.board[position] else {
                    return nil
                }
                return piece
            }
            .sorted(by: {
                $0.value > $1.value
            })
            .first
    }
}
