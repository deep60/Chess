//
//  TileView.swift
//  Chess
//
//  Created by P Deepanshu on 05/10/24.
//

import SwiftUI

struct TileView: View {
    let shouldShowPosition = false
    var viewModel: GameViewModel
    var position: Position
    
    var isCurrentlyHighlighted: Bool {
        return viewModel.selection?.grid[position] ?? false
    }
    
    var highlightColor: Color {
        guard viewModel.selection?.origin != self.position else {
            return Color.yellow
        }
        
        guard !isCurrentlyHighlighted else {
            if let piece = viewModel.game.board[self.position], piece.owner != viewModel.game.turn {
                return Color.red
            } else {
                return Color.blue
            }
        }
        
        return Color.clear
    }
    
    var body: some View {
        Button(action: {
            guard self.viewModel.state == .awaitingInput else {
                return
            }
            self.viewModel.select(self.position)
        }, label: {
            ZStack {
                Board.colors[position]
                self.highlightColor.opacity(0.5)
                PieceView(piece: self.viewModel.game.board[position])
                
                VStack {
                    Spacer()
                    Text(shouldShowPosition ? self.position.description : "")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.black)
                }
            }
            //.border(Color.black, width: 1)
        })
    }
}

#Preview {
    TileView_Previews.previews
}

struct TileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            tileViewWithNoHighlighting()
        }
        .previewLayout(.fixed(width: 100, height: 100))
    }
    
    static func tileViewWithNoHighlighting() -> some View {
        let vm = GameViewModel(game: .standard)
        return TileView(viewModel: vm, position: Position(rank: .E, row: .four))
    }
}
