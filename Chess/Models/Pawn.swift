//
//  Pawn.swift
//  Chess
//
//  Created by P Deepanshu on 26/09/24.
//

import Foundation

class Pawn: Piece {
    
    required init(owner: Team) {
        super.init(owner: owner)
    }
    
    override var value: Int {
        return 1
    }
    
    static let doubleMoveAllowedPositionsForWhitePawns = DirectedPos(position: Position(rank: .A, row: .two), perspective: .white).rightSpaces.map {
        $0.position
    } + [Position(rank: .A, row: .two)]
    
    static let doubleMoveAllowedPositionsForBlackPawns = DirectedPos(position: Position(rank: .A, row: .seven), perspective: .black).leftSpaces.map {
        $0.position
    } + [Position(rank: .A, row: .seven)]
    
    static let promotionRequiredPositionsForWhitePawns = DirectedPos(position: Position(rank: .A, row: .eight), perspective: .white).rightSpaces.map {
        $0.position
    } + [Position(rank: .A, row: .eight)]
    
    static let promotionRequiredPositionsForBlackPawns = DirectedPos(position: Position(rank: .A, row: .one), perspective: .white).leftSpaces.map {
        $0.position
    } + [Position(rank: .A, row: .one)]
    
    override func possibleMoves(position: Position, game: Game) -> Set<Move> {
        let directedPos = position.fromPrespective(team: owner)
        
        let frontMoves: Position? = {
            guard let space = directedPos.front?.position else {
                return nil
            }
            
            let collidingPiece = game.board[space]
            
            switch collidingPiece {
            case .none:
                return space
            case .some(_):
                return nil
            }
        }()
        
        let frontLeftMoves: Position? = {
            guard let space = directedPos.diagonalLeftFront?.position else {
                return nil
            }
            
            let collidingPiece = game.board[space]
            
            switch collidingPiece {
            case .none:
                return nil
            case .some(let collidingPiece):
                if collidingPiece.owner == self.owner {
                    return nil
                } else {
                    return space
                }
            }
        }()
        
        let frontRightMoves: Position? = {
            guard let space = directedPos.diagonalRightFront?.position else {
                return nil
            }
            
            let collidingPiece = game.board[space]
            
            switch collidingPiece {
            case .none:
                return nil
            case .some(let collidingPiece):
                if collidingPiece.owner == self.owner {
                    return nil
                } else {
                    return space
                }
            }
        }()
        
        let allMovePosition = [frontMoves, frontLeftMoves, frontRightMoves].compactMap({
            $0
        })
        
        let normalMoves: [Move] = allMovePosition.map { destination in
            if (owner == .white ? Pawn.promotionRequiredPositionsForWhitePawns : Pawn.promotionRequiredPositionsForBlackPawns).contains(destination) {
                return Move(origin: position, destination: destination, capturedPiece: game.board[destination], kind: .needsPromotion)
            } else {
                return Move(origin: position, destination: destination, capturedPiece: game.board[destination])
            }
        }
        
        let doubleMove = { () -> Move? in
            switch self.owner {
            case .white:
                guard Pawn.doubleMoveAllowedPositionsForWhitePawns.contains(position) else {
                    return nil
                }
            case .black:
                guard Pawn.doubleMoveAllowedPositionsForBlackPawns.contains(position) else {
                    return nil
                }
            }
            
            guard let front = directedPos.front?.position, game.board[front] == nil else {
                return nil
            }
            
            guard let doubleMoveDestination = directedPos.front?.front?.position, game.board[doubleMoveDestination] == nil else {
                return nil
            }
            
            return Move(origin: position, destination: doubleMoveDestination, capturedPiece: game.board[doubleMoveDestination])
        }()
        
        let enPassantMove = { () -> Move? in
            guard let lastMove = game.history.last,
                let piece = game.board[lastMove.destination],
                let pawn = piece as? Pawn else {
                return nil
            }
            
            assert(pawn.owner == game.turn.opponent)
            
            switch game.turn {
            case .white:
                guard Pawn.doubleMoveAllowedPositionsForBlackPawns.contains(lastMove.origin),
                      abs(lastMove.origin.row.rawValue - lastMove.destination.row.rawValue) == 2 else {
                    return nil
                }
            case .black:
                guard Pawn.doubleMoveAllowedPositionsForWhitePawns.contains(lastMove.origin),
                      abs(lastMove.origin.row.rawValue - lastMove.destination.row.rawValue) == 2 else {
                    return nil
                }
            }
            guard lastMove.destination != directedPos.left?.position else {
                return Move(origin: position, destination: directedPos.diagonalLeftFront!.position, capturedPiece: game.board[lastMove.destination], kind: .enPassant)
            }
            
            guard lastMove.destination != directedPos.right?.position else {
                return Move(origin: position, destination: directedPos.diagonalRightFront!.position, capturedPiece: game.board[lastMove.destination], kind: .enPassant)
            }
            
            return nil
        }()
        
        return Set(normalMoves + [doubleMove, enPassantMove].compactMap( {
            $0
        }))
    }
    
    override func threatenedPositions(position: Position, game: Game) -> BooleanChessGrid {
        let directedPos = position.fromPrespective(team: owner)
        
        let frontLeftThreat: Position? = {
            guard let space = directedPos.diagonalLeftFront?.position else {
                return nil
            }
            
            switch game.board[space] {
            case .none:
                return space
            case .some(let collidingpiece):
                if collidingpiece.owner == self.owner {
                    return nil
                } else {
                    return space
                }
            }
        }()
        
        let frontRightThreat: Position? = {
            guard let space = directedPos.diagonalRightFront?.position else {
                return nil
            }
            
            switch game.board[space] {
            case .none:
                return space
            case .some(let collidingpiece):
                if collidingpiece.owner == self.owner {
                    return nil
                } else {
                    return space
                }
            }
        }()
        
        return BooleanChessGrid(position: [frontLeftThreat, frontRightThreat].compactMap({ $0 }))
    }
}
