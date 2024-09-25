//
//  BooleanChessGrid.swift
//  Chess
//
//  Created by P Deepanshu on 25/09/24.
//

import Foundation

typealias BooleanChessGrid = ChessGrid<Bool>

extension BooleanChessGrid {
    static let `false` = BooleanChessGrid(array: Array(repeating: false, count: 64))
    static let `true` = BooleanChessGrid(array: Array(repeating: true, count: 64))
    
    init() {
        self = BooleanChessGrid(array: Array(repeating: false, count: 64))
    }
    
    init(position: [Position]) {
        self = BooleanChessGrid()
        for position in position {
            self[position] = true
        }
    }
}
