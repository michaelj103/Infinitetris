//
//  DefaultPieceIdentifier.swift
//  
//
//  Created by Michael Brandt on 4/5/23.
//

import TetrominoCore

struct DefaultPieceIdentifier: PieceIdentifying {
    func getPiece(for id: Int) -> Piece {
        return Piece.defaultPieces[id]
    }
}
