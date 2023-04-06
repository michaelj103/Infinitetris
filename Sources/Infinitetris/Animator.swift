//
//  Animator.swift
//  
//
//  Created by Michael Brandt on 4/5/23.
//

import TetrominoCore

protocol Animator {
    var requiresPrecomputation: Bool { get }
    // allEvents is nil unless requiresPrecomputation is true
    func prepare(dimensions: Size, allEvents: [SimulationEvent]?)
//    func animateEvent(_ event: SimulationEvent, completion: ()->Void)
    func animateEvent(_ event: SimulationEvent)
    func finalize()
}
