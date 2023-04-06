//
//  Runner.swift
//  
//
//  Created by Michael Brandt on 4/5/23.
//

import TetrominoCore

class Runner {
    private let solver: MoveSolver
    private let moveGenerator: MoveEventGenerator
    private let animator: Animator
    
    private var eventQueue: [SimulationEvent] = []
    
    init(_ dimensions: Size, animator: Animator) {
        solver = MoveSolver(dimensions)
        moveGenerator = MoveEventGenerator(dimensions)
        self.animator = animator
    }
    
    private var runningContinuously = false
    private var completion: (()->Void)?
    func runFinite(_ numClears: Int, completion: @escaping ()->Void) {
        precondition(numClears > 0, "Must run with positive number of clears")
        for _ in 0..<numClears {
            guard _generateClearance() else { preconditionFailure("Failed to generate clearance") }
        }
        animator.prepare(dimensions: solver.board.size, allEvents: eventQueue)
        
        self.completion = completion
        runningContinuously = false
        _runNextEvent()
    }
    
    func run() {
        precondition(!animator.requiresPrecomputation, "Animator does not support infinite play")
        for _ in 0..<2 {
            guard _generateClearance() else { preconditionFailure("Failed to generate clearance") }
        }
        
        runningContinuously = true
        animator.prepare(dimensions: solver.board.size, allEvents: nil)
        _runNextEvent()
    }
    
    private func _runNextEvent() {
        guard !eventQueue.isEmpty else {
            animator.finalize()
            if let completion {
                completion()
            }
            completion = nil
            return
        }
        
        let nextEvent = eventQueue.removeFirst()
        if runningContinuously, case .clear = nextEvent {
            if !_generateClearance() {
                preconditionFailure("Failed to generate clearance")
            }
        }
        animator.animateEvent(nextEvent) {
            self._runNextEvent()
        }
    }
        
    private func _generateClearance() -> Bool {
        let order = _clearanceOrder()
        var moves: [PlacedPiece] = []
        for rows in order {
            moves = solver.runUntilNextClear(rows)
            if moves.count > 0 {
                break
            }
        }
        
        guard moves.count > 0 else { return false }
        let moveEvents = moveGenerator.generateMoveEvents(moves, store: DefaultPieceIdentifier())
        eventQueue.append(contentsOf: moveEvents)
        let clearedRows = solver.board.clearCompletedRows()
        let clearEvent = ClearEvent(clearedRows: clearedRows)
        eventQueue.append(.clear(clearEvent))
        return true
    }
    
    private func _clearanceOrder() -> [Int] {
        var order: [Int] = []
        let weights: [Int:Int] = [ 4: 50, 3: 25, 2: 15, 1: 10 ]
        var remaining = Array(1...4)
        while remaining.count > 1 {
            let total = remaining.reduce(0) { $0 + weights[$1]! }
            var randIdx = Int.random(in: 0..<total)
            var selectedIdx: Int?
            for (idx, rows) in remaining.enumerated() {
                let weight = weights[rows]!
                if randIdx < weight {
                    selectedIdx = idx
                    break
                }
                randIdx -= weight
            }
            
            order.append(remaining[selectedIdx!])
            remaining.remove(at: selectedIdx!)
        }
        order.append(contentsOf: remaining)
        return order
    }
}
