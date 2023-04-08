//
//  MoveState.swift
//  
//
//  Created by Michael Brandt on 3/29/23.
//

import TetrominoCore

struct MoveState {
    var pieceIdx: Int = 0
    var pieceOrder: [Int]
    var pieceID: Int {
        return pieceOrder[pieceIdx]
    }
    
    var rotationIdx: Int = 0
    var rotationOrder: [Int]
    var rotation: Int {
        return rotationOrder[rotationIdx]
    }
    
    var columnIdx: Int = 0
    var columnOrder: [Int]
    var column: Int {
        return columnOrder[columnIdx]
    }
    
    static func randomMoveState(using rng: RandomSource, columnCount: Int = 10) -> MoveState {
        let pieceOrder = rng.shuffle(Array(0..<Piece.defaultPieces.count))
        let rotationOrder = rng.shuffle(Array(0..<4))
        let columnOrder = rng.shuffle(Array(0..<columnCount))
        var state = MoveState(pieceOrder: pieceOrder, rotationOrder: rotationOrder, columnOrder: columnOrder)
        state.setBaseRotation()
        return state
    }
    
    private mutating func setBaseRotation() {
        let piece = Piece.defaultPieces[pieceID]
        for (idx, rotation) in rotationOrder.enumerated() {
            if rotation < piece.rotations.count {
                rotationIdx = idx
                break
            }
        }
    }
    
    mutating func increment() -> Bool {
        // first, attempt to increment column
        if columnIdx + 1 < columnOrder.count {
            columnIdx += 1
            return true
        }
        
        // done with columns, attempt to increment rotation
        let piece = Piece.defaultPieces[pieceID]
        for nextRotationIdx in (rotationIdx+1)..<rotationOrder.count {
            let nextRotation = rotationOrder[nextRotationIdx]
            if nextRotation < piece.rotations.count {
                // valid rotation
                rotationIdx = nextRotationIdx
                columnIdx = 0
                return true
            }
        }
        
        // no more valid rotations, next piece
        if pieceIdx + 1 < pieceOrder.count {
            pieceIdx += 1
            setBaseRotation()
            columnIdx = 0
            return true
        }
        
        // tried everything
        return false
    }
}
