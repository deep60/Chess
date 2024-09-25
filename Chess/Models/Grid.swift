//
//  Grid.swift
//  Chess
//
//  Created by P Deepanshu on 24/09/24.
//

import Foundation

struct Grid<Element> {
    typealias Column = [Element]
    
    var columns: [Column]
    let rowSize: Int
    let columnSize: Int
    
    init(rowSize: Int, columnSize: Int, array: [Element]) {
        precondition(array.count == rowSize * columnSize, "grid and array mismatch")
        
        var columns = Array(repeating: Column(), count: rowSize)
        var current = 0
        for element in array {
            columns[current].append(element)
            
            if current == columns.count - 1 {
                current = 0
            } else {
                current += 1
            }
        }
        
        self.columns = columns
        self.rowSize = rowSize
        self.columnSize = columnSize
    }
    
    subscript(row: Int, column: Int) -> Element {
        get {
            return columns[column][row]
        }
        
        set {
            columns[column][row] = newValue
        }
    }
    
    subscript(position: IndexPath) -> Element {
        get {
            return self[position.row, position.column]
        }
        
        set {
            self[position.row, position.column] = newValue
        }
    }
}

extension Grid: Collection {
    func index(after i: IndexPath) -> IndexPath {
        if (i.column == columnSize - 1) {
            return IndexPath(row: i.row + 1, column: 0)
        } else {
            return IndexPath(row: i.row, column: i.column + 1)
        }
    }
    typealias Index = IndexPath
    
    var startIndex: IndexPath {
        return IndexPath(indexes: [0, 0])
    }
    
    var endIndex: IndexPath {
        return IndexPath(indexes: [0, columnSize])
    }
}

extension Grid: BidirectionalCollection {
    func index(before i: IndexPath) -> IndexPath {
        if (i.column == 0) {
            return IndexPath(row: i.row - 1, column: columnSize - 1)
        } else {
            return IndexPath(row: i.row, column: i.column - 1)
        }
    }
}

extension Grid: RandomAccessCollection {}

extension Grid: CustomStringConvertible {
    var description: String {
        return columns.reduce("") { (currentResult, column) -> String in
            return currentResult + String(describing: column) + "\n"
        }
    }
}

extension Grid: Equatable where Element: Equatable {}
extension Grid: Hashable where Element: Hashable {}

extension Grid where Element: ExpressibleByNilLiteral {
    init(rowSize: Int, columnSize: Int) {
        let emptyArray = Array<Element>(repeating: nil, count: rowSize * columnSize)
        self = Grid(rowSize: rowSize, columnSize: columnSize, array: emptyArray)
    }
}
