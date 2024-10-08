//
//  ChackHandler.swift
//  Chess
//
//  Created by P Deepanshu on 29/09/24.
//

import Foundation

protocol CheckHandlerProtocol {
    func state(team: Team, game: Game) -> CheckHandler.State
}

struct CheckHandler {
    enum State {
        case none
        case check
        case checkmate
    }
    
    func state(team: Team, game: Game) -> State {
        let whiteKingPosition = game.kingPosition(team: .white)
        let blackKingPosition = game.kingPosition(team: .black)
        let whitePlayerThreatenedPosition = game.positionsThreatened(team: .white)
        let blackPlayerThreatenedPosition = game.positionsThreatened(team: .black)
        
        switch team {
        case .white:
            let whitePlayerStatus: State = {
                let whiteKingIsThreatened = blackPlayerThreatenedPosition[whiteKingPosition]
                let allPossibleWhiteMoves = game.allMoves(team: .white)
                let allPossibleNewGameStates = allPossibleWhiteMoves.map {
                    game.performing($0)
                }
                
                if whiteKingIsThreatened {
                    guard game.turn == .white else {
                        return .checkmate
                    }
                    
                    let somePossibleWhiteMoveEliminatesKingThreat = oneOfThese(scenarios: allPossibleNewGameStates, team: .white)
                    
                    return somePossibleWhiteMoveEliminatesKingThreat ? .check : .checkmate
                } else {
                    guard game.turn == .white else {
                        return .none
                    }
                    
                    let somePossibleWhiteMoveDoesNotIntroduceKingThreat = oneOfThese(scenarios: allPossibleNewGameStates, team: .white)
                    return somePossibleWhiteMoveDoesNotIntroduceKingThreat ? .none : .checkmate
                }
            }()
            
            return whitePlayerStatus
        case .black:
            let blackPlayerStatus: State = {
                let blackKingIsThreatened = whitePlayerThreatenedPosition[blackKingPosition]
                let allPossibleBlackMoves = game.allMoves(team: .black)
                let allPossibleNewGameStates = allPossibleBlackMoves.map {
                    game.performing($0)
                }
                
                if blackKingIsThreatened {
                    guard game.turn == .black else {
                        return .checkmate
                    }
                    
                    let somePossibleBlackMoveEliminatesKingThreat = oneOfThese(scenarios: allPossibleNewGameStates, team: .black)
                    
                    return somePossibleBlackMoveEliminatesKingThreat ? .check : .checkmate
                } else {
                    guard game.turn == .black else {
                        return .none
                    }
                    
                    let somePossibleBlackMoveDoesNotIntroduceKingThreat = oneOfThese(scenarios: allPossibleNewGameStates, team: .black)
                    return somePossibleBlackMoveDoesNotIntroduceKingThreat ? .none : .checkmate
                }
            }()
            return blackPlayerStatus
        }
    }
    
    func oneOfThese(scenarios: [Game], team: Team) -> Bool {
        scenarios
            .filter { scenario in
            let playerNewKingPosition = scenario.kingPosition(team: team)
            let opposingPlayerNewThreatenedPositions = scenario.positionsThreatened(team: team.opponent)
            let playerKingIsThreatenedInThisScenario = opposingPlayerNewThreatenedPositions[playerNewKingPosition]
            return !playerKingIsThreatenedInThisScenario
        }
        .count > 0
    }
    
    func validMoves(possibleMoves: Set<Move>, game: Game) -> Set<Move> {
        let potentialNewScenatios: [Game] = possibleMoves.map { possibleMove in
            game.performing(possibleMove)
        }
        
        let validMoves: [Move] = zip(possibleMoves, potentialNewScenatios).compactMap {
            possibleMove, scenario in
            guard state(team: game.turn, game: scenario) == .none else {
                return nil
            }
            
            return possibleMove
        }
        
        return Set(validMoves)
    }
}
