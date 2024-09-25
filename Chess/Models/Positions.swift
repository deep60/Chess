//
//  Positions.swift
//  Chess
//
//  Created by P Deepanshu on 23/09/24.
//

import Foundation

struct Position: Equatable {
    let rank: Rank
    let row: Row
    
    init(rank: Rank, row: Row) {
        self.rank = rank
        self.row = row
    }
    
    init?(gridIndex: IndexPath) {
        guard gridIndex != IndexPath(row: 8, column: 0) else {
            self = Position(rank: .A, row: .end)
            return
        }
        
        guard let row = Row(rawValue: 8 - gridIndex.row),
              let rank = Rank(rawValue: gridIndex.column + 1) else {
                  return nil
        }
        
        self.rank = rank
        self.row = row
    }
    
    var gridIndex: IndexPath {
        let converteddRow = abs(row.rawValue - 8)
        let convertedRank = rank.rawValue - 1
        
        return IndexPath(row: converteddRow, column: convertedRank)
    }
    
    func isAdjacent(otherPosition: Position) -> Bool {
        let directedPos = DirectedPos(position: self, perspective: .white)
        let adjacentPos = [
            directedPos.front,
            directedPos.back,
            directedPos.left,
            directedPos.right,
            directedPos.diagonalLeftFront,
            directedPos.diagonalRightFront,
            directedPos.diagonalRightBack,
            directedPos.diagonalLeftBack,
        ].compactMap {
            $0?.position
        }
        
        return adjacentPos.contains(otherPosition)
    }
    
    func isValidPath(array: [Position]) -> Bool {
        guard !array.isEmpty else {
            return true
        }
        
        var iterator = array.makeIterator()
        var current = iterator.next()!
        
        while let nextElement = iterator.next() {
            guard current.isAdjacent(otherPosition: nextElement) else {
                return false
            }
            current = nextElement
        }
        return true
    }
}

extension Position: Comparable {
    static func < (lhs: Position, rhs: Position) -> Bool {
        return lhs.gridIndex < rhs.gridIndex
    }
}

extension Position: Hashable {
    
}

extension Position: CustomStringConvertible {
    var description: String {
        "\(rank) - \(row.rawValue)"
    }
}
