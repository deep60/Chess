//
//  GameView.swift
//  Chess
//
//  Created by P Deepanshu on 07/10/24.
//

import SwiftUI

struct GameView: View {
    
    var viewModel: GameViewModel
    @State var checkMate = false
    
    var body: some View {
        VStack {
            Text("\(viewModel.roster.blackPlayer.description) (black)")
            BoardView(viewModel: viewModel)
            Text("\(viewModel.roster.whitePlayer.description) (white)")
            HStack(alignment: .center) {
                StatusView(viewModel: viewModel)
            }
        }
        .padding()
        .alert("Checkmate", isPresented: $checkMate) {
            
        } message: {
            Text("Game Over.\(viewModel.game.turn.opponent) has won")
        }
        .onReceive(viewModel.checkmateOccured, perform: { _ in
            checkMate = true
        })
    }
}

#Preview {
    GameViewPreview.previews
}

struct GameViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            gameViewStandardGame()
        }
        .previewLayout(.fixed(width: 300, height: 100))
    }
    
    static func gameViewStandardGame() -> some View {
        let vm = GameViewModel(roster: Roster(whitePlayer: .human, blackPlayer: .human))
        return GameView(viewModel: vm)
            .previewLayout(.fixed(width: 350, height: 350))
    }
}

