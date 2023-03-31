//
//  LinearCongruentialGenerator.swift
//  
//
//  Created by Michael Brandt on 3/29/23.
//

struct LinearCongruentialGenerator: RandomNumberGenerator {
    private var value: UInt64
    // constants from glibc
    private let multiplier: UInt64 = 1103515245
    private let increment: UInt64 = 12345
    private let modulus: UInt64 = 0x80000000
    
    init(seed: UInt64) {
        value = seed % modulus
    }
    
    mutating func next() -> UInt64 {
        let next = ((value * multiplier) + increment) % modulus
        value = next
        return next
    }
}
