//
//  MoveSolver.swift
//  
//
//  Created by Michael Brandt on 3/29/23.
//

import TetrominoCore

class MoveSolver {
    var randomGenerator: RandomNumberGenerator = SystemRandomNumberGenerator()
    var maxAllowedGrowth = 6
    
    private var currentMoveState: MoveState? = nil
    private var previousStates: [MoveState] = []
    private var currentMoves: [PlacedPiece] = []
    private var board: PieceBoard
    
    // TODO: Some way to specify initial board state
    init(_ dimensions: Size) {
        board = PieceBoard(dimensions)
    }
    
    private enum SolverState {
        case Placing
        case Backtracking
        case Done
    }
    private var solverState = SolverState.Placing
    
    private var requiredClearanceCount = 4
    private var initialPlacementHeight = 0
    func runUntilNextClear(_ rowsToClear: Int) -> [PlacedPiece] {
        self.currentMoveState = nil
        self.previousStates = []
        self.currentMoves = []
        self.initialPlacementHeight = board.getFilledHeight()
        self.requiredClearanceCount = rowsToClear
        solverState = .Placing
        _runInternal()
        return currentMoves
    }
    
    private func _runInternal() {
        while true {
            switch solverState {
            case .Placing:
                _placeNextPiece()
            case .Backtracking:
                _backtrack()
            case .Done:
                return
            }
        }
    }
    
    private func _incrementState() -> Bool {
        if currentMoveState == nil {
            currentMoveState = MoveState.randomMoveState(using: &randomGenerator)
            return true
        } else {
            return currentMoveState!.increment()
        }
    }
    
    private func _placeNextPiece() {
        if !_incrementState() {
            // Tried all valid moves. need to backtrack
            currentMoveState = nil
            solverState = .Backtracking
            return
        }
        let currentState = currentMoveState!
        
        let pieceID = currentState.pieceID
        let piece = Piece.defaultPieces[pieceID]
        let rotationID = currentState.rotation
        let rotation = piece.rotations[rotationID]
        let column = currentState.column
        
        // place at the lowest row where this piece fits
        var placementType: ValidPlacementType?
        for row in (0..<board.size.height).reversed() {
            let pos = Point(x: column, y: row)
            if board.addPiece(rotation, at: pos) {
                let colRange = column..<(column + rotation.size.width)
                if let placement = _validatePlacement(colRange: colRange, upToRow: row) {
                    // added successfully. Push the move and state onto the stack
                    currentMoves.append(PlacedPiece(id: pieceID, rotation: rotationID, position: pos))
                    previousStates.append(currentState)
                    currentMoveState = nil
                    placementType = placement
                    break
                } else {
                    // Not valid placement by the current critera. Remove it
                    board.removePiece(rotation, at: pos)
                }
            }
        }
        
        if let placementType, case .Clearance = placementType {
            // We've placed a piece leading to a clearance
            solverState = .Done
        }
    }
    
    private enum ValidPlacementType {
        case Normal
        case Clearance(Int)
    }
    
    private func _validatePlacement(colRange: Range<Int>, upToRow: Int) -> ValidPlacementType? {
        // first check for clearances
        var clearedRows: Set<Int> = []
        let maxRow = min(board.size.height - 1, upToRow + 3)
        for row in upToRow...maxRow {
            var filledInRow = 0
            for col in 0..<board.size.width {
                if board.isFilled(at: Point(x: col, y: row)) {
                    filledInRow += 1
                } else {
                    break
                }
            }
            if filledInRow == board.size.width {
                clearedRows.insert(row)
            }
        }
        
        let clearedCount = clearedRows.count
        if clearedCount > 0 && clearedCount != requiredClearanceCount {
            // This triggers a clearance of the wrong number of rows, so it is invalid
            return nil
        }
        
        let newHeight = board.size.height - upToRow - clearedCount
        if newHeight - initialPlacementHeight > maxAllowedGrowth {
            return nil
        }
        
        // next, check for overhangs
        for col in colRange {
            var emptySeen = false
            for row in (upToRow...(board.size.height - 1)).reversed() {
                if clearedRows.contains(row) {
                    continue
                }
                if board.isFilled(at: Point(x: col, y: row)) {
                    if emptySeen {
                        // encountered a filled space after an empty in this column
                        // overhangs blanket disallowed currently
                        return nil
                    }
                } else {
                    emptySeen = true
                }
            }
        }
        
        if clearedCount > 0 {
            return .Clearance(clearedCount)
        } else {
            return .Normal
        }
    }
    
    private func _backtrack() {
        if previousStates.isEmpty {
            // we can't backtrack anymore. Failed to find a valid placement
            solverState = .Done
        } else {
            currentMoveState = previousStates.removeLast()
            currentMoves.removeLast()
        }
    }
}

fileprivate extension PieceBoard {
    func getFilledHeight() -> Int {
        for row in 0..<size.height {
            for col in 0..<size.width {
                if isFilled(at: Point(x: col, y: row)) {
                    return size.height - row
                }
            }
        }
        return 0
    }
}