//
//  DisplayBoard.swift
//  
//
//  Created by Michael Brandt on 4/5/23.
//

import TetrominoCore

struct DisplayColor {
    let r: UInt8
    let g: UInt8
    let b: UInt8
}

class DisplayBoard {
    private let board: PieceBoard<Int?>
    
    private var colorByID: [Int:DisplayColor] = [:]
    private var countByID: [Int:Int] = [:]
    
    private let colorMap = [
        "I": DisplayColor(r: 39, g: 147, b: 230),
        "O": DisplayColor(r: 220, g: 220, b: 20),
        "T": DisplayColor(r: 159, g: 23, b: 227),
        "S": DisplayColor(r: 23, g: 227, b: 43),
        "J": DisplayColor(r: 23, g: 47, b: 227),
        "Z": DisplayColor(r: 235, g: 20, b: 20),
        "L": DisplayColor(r: 247, g: 110, b: 5),
    ]
    
    init(dimensions: Size) {
        board = PieceBoard<Int?>(dimensions, unfilled: nil)
    }
    
    func getColor(at pt: Point) -> DisplayColor? {
        if let pieceID = board.getValue(at: pt) {
            return colorByID[pieceID]!
        } else {
            return nil
        }
    }
    
    func updateForAppear(_ appear: AppearEvent) {
        let placement = appear.placement
        let piece = Piece.defaultPieces[placement.id]
        let rotation = piece.rotations[placement.rotation]
        board.addPiece(rotation, at: placement.position, with: appear.pieceID)
        countByID[appear.pieceID] = piece.pipCount
        colorByID[appear.pieceID] = colorMap[piece.name]!
    }
    
    func updateForMove(_ move: MoveEvent) {
        let beforePlacement = move.beforeState
        let beforePiece = Piece.defaultPieces[beforePlacement.id]
        let beforeRotation = beforePiece.rotations[beforePlacement.rotation]
        board.removePiece(beforeRotation, at: beforePlacement.position)
        
        let afterPlacement = move.afterState
        let afterPiece = Piece.defaultPieces[afterPlacement.id]
        let afterRotation = afterPiece.rotations[afterPlacement.rotation]
        board.addPiece(afterRotation, at: afterPlacement.position, with: move.pieceID)
    }
    
    func updateForClear(_ clear: ClearEvent) {
        for row in clear.clearedRows {
            for x in 0..<board.size.width {
                let pt = Point(x: x, y: row)
                let pieceID = board.getValue(at: pt)!
                let remainingCount = countByID[pieceID]! - 1
                if remainingCount > 0 {
                    countByID[pieceID] = remainingCount
                } else {
                    countByID[pieceID] = nil
                    colorByID[pieceID] = nil
                }
            }
        }
        board.clearCompletedRows()
    }
}
