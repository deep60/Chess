//
//  DirectedPos.swift
//  Chess
//
//  Created by P Deepanshu on 23/09/24.
//

import Foundation

struct  DirectedPos {
    let position: Position
    let perspective: Team
    
    func allSpaces(calculateNextPos: (DirectedPos) -> DirectedPos?) -> [DirectedPos] {
        var res = [DirectedPos]()
        var current = self
        
        while let nextPos = calculateNextPos(current) {
            res.append(nextPos)
            current = nextPos
        }
        return res
    }
    
    var front: DirectedPos? {
        guard let newRow = Row(rawValue: perspective == .white ? position.row.rawValue + 1 : position.row.rawValue - 1) else {
            return nil
        }
        
        let newPos = Position(rank: position.rank, row: newRow)
        return DirectedPos(position: newPos, perspective: perspective)
    }
    
    var back: DirectedPos? {
        guard let newRow = Row(rawValue: perspective == .white ? position.row.rawValue - 1 : position.row.rawValue + 1) else {
            return nil
        }
        
        let newPos = Position(rank: position.rank, row: newRow)
        return DirectedPos(position: newPos, perspective: perspective)
    }
    
    var right: DirectedPos? {
        guard let newRank = Rank(rawValue: perspective == .white ? position.rank.rawValue + 1 : position.rank.rawValue - 1) else {
            return nil
        }
        
        let newPos = Position(rank: newRank, row: position.row)
        return DirectedPos(position: newPos, perspective: perspective)
    }
    
    var left: DirectedPos? {
        guard let newRank = Rank(rawValue: perspective == .white ? position.rank.rawValue - 1 : position.rank.rawValue + 1) else {
            return nil
        }
        
        let newPos = Position(rank: newRank, row: position.row)
        return DirectedPos(position: newPos, perspective: perspective)
    }
    
    var diagonalLeftFront: DirectedPos? {
        return self
            .front?.left
    }
    var diagonalRightFront: DirectedPos? {
        return self
            .front?.right
    }
    var diagonalLeftBack: DirectedPos? {
        return self
            .left?.back
    }
    var diagonalRightBack: DirectedPos? {
        return self
            .right?.back
    }
    
    var frontSpaces: [DirectedPos] {
        return allSpaces { position in
            position.front
        }
    }
    
    var backSpaces: [DirectedPos] {
        return allSpaces { position in
            position.back
        }
    }
    
    var leftSpaces: [DirectedPos] {
        return allSpaces { position in
            position.left
        }
    }
    
    var rightSpaces: [DirectedPos] {
        return allSpaces { position in
            position.right
        }
    }
    
    var diagonalLeftFrontSpaces: [DirectedPos] {
        return allSpaces { position in
            position.diagonalLeftFront
        }
    }
    
    var diagonalRightFrontSpaces: [DirectedPos] {
        return allSpaces { position in
            position.diagonalRightFront
        }
    }
    
    var diagonalLeftBackSpaces: [DirectedPos] {
        return allSpaces { position in
            position.diagonalLeftBack
        }
    }
    
    var diagonalRightBackSpaces: [DirectedPos] {
        return allSpaces { position in
            position.diagonalRightBack
        }
    }
}
