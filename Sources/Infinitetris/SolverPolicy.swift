//
//  SolverPolicy.swift
//  
//
//  Created by Michael Brandt on 4/4/23.
//

import TetrominoCore

struct SolverPolicy {
    let maxIntermediateGrowth: Int
    let maxFinalGrowth: Int
    
    static let emptyPolicy = SolverPolicy(maxIntermediateGrowth: 0, maxFinalGrowth: 0)
}

protocol SolverPolicyProvider {
    func policy(initialBoard: PieceBoard) -> SolverPolicy
}

struct StandardPolicyProvider: SolverPolicyProvider {
    func policy(initialBoard: PieceBoard) -> SolverPolicy {
        let boardHeight = initialBoard.getFilledHeight()
        
        let maxIntermediate = 16 - boardHeight
        let maxTotal = min(15 - boardHeight, 6)
        
        return SolverPolicy(maxIntermediateGrowth: maxIntermediate, maxFinalGrowth: maxTotal)
    }
}
