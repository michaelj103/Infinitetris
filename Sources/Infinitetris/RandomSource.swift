//
//  RandomSource.swift
//  
//
//  Created by Michael Brandt on 4/7/23.
//

import Foundation

class RandomSource {
    private let type: SourceType
    private var seededRNG: LinearCongruentialGenerator
    init() {
        type = .system
        seededRNG = LinearCongruentialGenerator(seed: 0)
    }
    
    init(seed: UInt64) {
        type = .seeded
        seededRNG = LinearCongruentialGenerator(seed: seed)
    }
    
    func randRange(_ range: Range<Int>) -> Int {
        switch type {
        case .system:
            return Int.random(in: range)
        case .seeded:
            return (Int(seededRNG.next()) % range.upperBound) + range.startIndex
        }
    }
    
    func shuffle<A:RandomAccessCollection>(_ array: A) -> [A.Element] {
        switch type {
        case .system:
            return array.shuffled()
        case .seeded:
            var shuff = Array(array)
            for i in 0..<shuff.count {
                let j = randRange(0..<shuff.count)
                shuff.swapAt(i, j)
            }
            return shuff
        }
    }
    
    private enum SourceType {
        case system
        case seeded
    }
}
