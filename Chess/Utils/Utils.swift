//
//  Utils.swift
//  Chess
//
//  Created by P Deepanshu on 22/09/24.
//

import SwiftUI


enum Team {
    case white
    case black
    
    var component: Team {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        }
    }
    
    var color: Color {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        }
    }
}

extension Team: CustomStringConvertible {
    var description: String {
        switch self {
        case .white:
            return "white"
        case .black:
            return "black"
        }
    }
}

protocol AritificalIntellignence {
    var name: String {get}
}

enum Player {
    case human
    case AI(AritificalIntellignence)
}

extension Player: CustomStringConvertible {
    var description: String {
        switch self {
        case .human:
            return "human"
        case .AI(let ai):
            return ai.name
        }
    }
    
}

enum Rank: Int {
    case A = 1
    case B
    case C
    case D
    case E
    case F
    case G
    case H
}

enum Row: Int {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    
    case end = -1
}

extension IndexPath {
    init(row: Int, column: Int) {
        self.init(indexes: [column, row])
    }
    
    var row: Int {
        return self[1]
    }
    
    var column: Int {
        return self[0]
    }
}

struct Rooster {
    let whitePlayer: Player
    let blackPlayer: Player
    
    init(whitePlayer: Player, blackPlayer: Player) {
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
    }
    
    subscript(team: Team) -> Player {
        switch team {
        case .white:
            return whitePlayer
        case .black:
            return blackPlayer
        }
    }
}

enum Kind: Hashable {
    case standard
    case castle
    case enPassant
    case needsPromotion
    case promotion(Piece)
}

extension Array where Element: Hashable {
    func toSet() -> Set<Element> {
        return Set(self)
    }
}
