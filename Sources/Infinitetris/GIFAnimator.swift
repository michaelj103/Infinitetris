//
//  GIFAnimator.swift
//  
//
//  Created by Michael Brandt on 4/5/23.
//

#if os(macOS)

import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers
import TetrominoCore

class GIFAnimator: Animator {
    
    private var imageDest: CGImageDestination?
    private var displayBoard: PieceBoard<Int?>?
    
    var requiresPrecomputation: Bool { return true }
    
    func prepare(dimensions: Size, allEvents: [SimulationEvent]?) {
        if #available(macOS 13.0, *) {
            let url = URL(filePath: "/Users/mjb/Desktop/infinitetris.gif")
            let properties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount:0]]
            imageDest = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, allEvents!.count, properties as CFDictionary)
            displayBoard = PieceBoard<Int?>(dimensions, unfilled: nil)
        } else {
            preconditionFailure()
        }
    }
    
    func animateEvent(_ event: SimulationEvent) {
        switch event {
        case .appear(let appearEvent):
            _updateForAppear(appearEvent)
            _addFrame(duration: appearEvent.duration)
        case .move(let moveEvent):
            _updateForMove(moveEvent)
            _addFrame(duration: moveEvent.duration)
        case .clear(let clearEvent):
            _updateForClear(clearEvent)
            _addFrame(duration: 0.5)
        }
    }
    
    private func _updateForAppear(_ appear: AppearEvent) {
        let placement = appear.placement
        let piece = Piece.defaultPieces[placement.id]
        let rotation = piece.rotations[placement.rotation]
        displayBoard!.addPiece(rotation, at: placement.position, with: appear.pieceID)
    }
    
    private func _updateForMove(_ move: MoveEvent) {
        let beforePlacement = move.beforeState
        let beforePiece = Piece.defaultPieces[beforePlacement.id]
        let beforeRotation = beforePiece.rotations[beforePlacement.rotation]
        displayBoard!.removePiece(beforeRotation, at: beforePlacement.position)
        
        let afterPlacement = move.afterState
        let afterPiece = Piece.defaultPieces[afterPlacement.id]
        let afterRotation = afterPiece.rotations[afterPlacement.rotation]
        displayBoard!.addPiece(afterRotation, at: afterPlacement.position, with: move.pieceID)
    }
    
    private func _updateForClear(_ clear: ClearEvent) {
        displayBoard!.clearCompletedRows()
    }
    
    private func _addFrame(duration: Double) {
        let count = 32 * 64 * 4
        var data = [UInt8](repeating: 0, count: count)
        for py in 0..<64 {
            for px in 0..<32 {
                let isFilled: Bool
                if px >= 1 && px < 31 && py >= 4 {
                    let boardX = (px - 1) / 3
                    let boardY = (py - 4) / 3
                    isFilled = displayBoard!.isFilled(at: Point(x: boardX, y: boardY))
                } else {
                    isFilled = false
                }
                
                let baseIdx = ((py * 32) + px) * 4
                if isFilled {
                    data[baseIdx] = 180
                    data[baseIdx + 1] = 180
                    data[baseIdx + 2] = 180
                    data[baseIdx + 3] = 255
                } else {
                    data[baseIdx] = 255
                    data[baseIdx + 1] = 255
                    data[baseIdx + 2] = 255
                    data[baseIdx + 3] = 255
                }
            }
        }
        
        let context = CGContext.init(data: &data, width: 32, height: 64, bitsPerComponent: 8, bytesPerRow: 128, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let image = context?.makeImage() else {
            preconditionFailure("Failed to make image")
        }
        
        let delaySeconds = ceil(duration * 100.0) / 100.0
        let properties = [ kCGImagePropertyGIFDictionary : [ kCGImagePropertyGIFUnclampedDelayTime : delaySeconds]]
        CGImageDestinationAddImage(imageDest!, image, properties as CFDictionary)
    }
    
    func finalize() {
        if !CGImageDestinationFinalize(imageDest!) {
            print("ImageIO error")
        }
        imageDest = nil
    }
    
    
}

#endif
