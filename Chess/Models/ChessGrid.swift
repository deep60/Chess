//
//  ChessGrid.swift
//  Chess
//
//  Created by P Deepanshu on 24/09/24.
//

import Foundation

struct ChessGrid<Element> {
    
    var grid: Grid<Element>
    
    init(array: [Element]) {
        self.grid = Grid(rowSize: 8, columnSize: 8, array: array)
    }
    
    init(repeating: Element) {
        self.grid = Grid<Element>(rowSize: 8, columnSize: 8, array: Array(repeating: repeating, count: 64))
    }
    
    subscript(position: Position) -> Element {
        get {
            return grid[position.gridIndex]
        }
        
        set {
            grid[position.gridIndex] = newValue
        }
    }
}

extension ChessGrid: Equatable where Element: Equatable {}
extension ChessGrid: Hashable where Element: Hashable {}

extension ChessGrid: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
    
    init(arrayLiteral elements: Element...) {
        self = ChessGrid(array: elements)
    }
}

extension ChessGrid where Element: ExpressibleByNilLiteral {
    init() {
        self.grid = Grid<Element>(rowSize: 8, columnSize: 8)
    }
}

extension ChessGrid: Collection {
    typealias Index = Position
    
    func index(after i: Position) -> Position {
        Position(gridIndex: grid.index(after: i.gridIndex))!
    }
    
    var startIndex: Position {
        return Position(gridIndex: grid.startIndex)!
    }
    
    var endIndex: Position {
        return Position(gridIndex: grid.endIndex)!
    }
}

extension ChessGrid: BidirectionalCollection {
    func index(before i: Position) -> Position {
        Position(gridIndex: grid.index(before: i.gridIndex))!
    }
}

extension ChessGrid: RandomAccessCollection {}
extension ChessGrid: CustomStringConvertible {
    var description: String {
        return grid.description
    }
}
