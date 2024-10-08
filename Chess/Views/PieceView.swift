//
//  PieceView.swift
//  Chess
//
//  Created by P Deepanshu on 05/10/24.
//

import SwiftUI

struct PieceView: View {
    
    let piece: Piece?
    
    var body: some View {
        ZStack {
            piece?.image
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    PieceView(piece: King(owner: .black))
        .previewLayout(.fixed(width: 250, height: 250))
}
