//
//  BoardView.swift
//  Chess
//
//  Created by P Deepanshu on 05/10/24.
//

import SwiftUI

struct BoardView: View {
    
    var viewModel: GameViewModel
    @State private var isShowingPromotion = false
    @State private var selectedPromotionType: PromotionType? = nil
    enum PromotionType: CaseIterable, Identifiable {
        case queen, rook, bishop, knight
        
        var id: Self {
            self
        }
    }
    
    func handlePromotion(promotionType: PromotionType) {
        let piece: Piece.Type
        
        switch promotionType {
        case .queen: piece =
            Queen.self
        case .rook: piece =
            Rook.self
        case .bishop: piece =
            Bishop.self
        case .knight: piece =
            Knight.self
        }
        
        viewModel.handlePromotion(promotionType: piece)
        isShowingPromotion = false
        selectedPromotionType = nil
    }
    
    func position(row: Int, column: Int) -> Position {
        return Position(gridIndex: IndexPath(row: row, column: column))!
    }
    
    static let spacing: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .phone ? 4 : 8
    }()
    
    var body: some View {
        ZStack {
            VStack(spacing: BoardView.spacing) {
                ForEach(0..<8) { row in
                    HStack(spacing: BoardView.spacing) {
                        ForEach(0..<8) { column in
                            TileView(viewModel: self.viewModel, position: self.position(row: row, column: column))
                        }
                    }
                }
            }
            .padding(BoardView.spacing)
            .border(Color.black, width: 0.5)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
            .onReceive(viewModel.shouldPromptForPromotion, perform: { _ in
                self.isShowingPromotion = true
            })
            .confirmationDialog("Promote", isPresented: $isShowingPromotion) {
                ForEach(PromotionType.allCases) { promotionType in
                    Button(String(describing: promotionType)) {
                        self.selectedPromotionType = promotionType
                    }
                }
            }
            .onChange(of: selectedPromotionType) { _, newPromotionType in
                if let promotionType = newPromotionType {
                    switch promotionType {
                    case .queen:
                        handlePromotion(promotionType: .queen)
                    case .rook:
                        handlePromotion(promotionType: .rook)
                    case .knight:
                        handlePromotion(promotionType: .knight)
                    case .bishop:
                        handlePromotion(promotionType: .bishop)
                    }
                }
            }
        }
    }
}

#Preview { 
    BoardView_Previews.previews
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            boardViewStandardGame()
        }
    }
    
    static func boardViewStandardGame() -> some View {
        let vm = GameViewModel(game: .standard)
        return BoardView(viewModel: vm)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
