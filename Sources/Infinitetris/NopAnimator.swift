//
//  NopAnimator.swift
//  
//
//  Created by Michael Brandt on 4/6/23.
//

import Foundation
import TetrominoCore

class NopAnimator: Animator {
    var requiresPrecomputation: Bool = false
    
    private var displayBoard: DisplayBoard?
    
    func prepare(dimensions: TetrominoCore.Size, allEvents: [SimulationEvent]?) {
        displayBoard = DisplayBoard(dimensions: dimensions)
    }
    
    func animateEvent(_ event: SimulationEvent, completion: @escaping () -> Void) {
        switch event {
        case .appear(let appearEvent):
            displayBoard!.updateForAppear(appearEvent)
        case .move(let moveEvent):
            displayBoard!.updateForMove(moveEvent)
        case .clear(let clearEvent):
            displayBoard!.updateForClear(clearEvent)
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    func finalize() {
        
    }
    
    
}
