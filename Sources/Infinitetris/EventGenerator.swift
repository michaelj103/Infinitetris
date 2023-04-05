//
//  EventGenerator.swift
//  
//
//  Created by Michael Brandt on 4/4/23.
//

import TetrominoCore

struct MoveEvent {
    let pieceID: Int
    let beforeState: PlacedPiece
    let afterState: PlacedPiece
    let duration: Double
}

struct ClearEvent {
    let clearedRows: Set<Int>
}

enum SimulationEvent {
    case move(MoveEvent)
    case clear(ClearEvent)
}

class MoveEventGenerator {
    let size: Size
    private var nextPieceID = 0
    
    init(_ dim: Size) {
        size = dim
    }
    
    private func _getNextID() -> Int {
        let id = nextPieceID
        nextPieceID += 1
        return id
    }
    
    func generateMoveEvents(_ moves: [PlacedPiece], store: PieceIdentifying) -> [SimulationEvent] {
        var allMoveEvents: [SimulationEvent] = []
        for move in moves {
            allMoveEvents += _moveEventsForPlacement(move, store: store, pieceID: _getNextID())
        }
        return allMoveEvents
    }

    private func _moveEventsForPlacement(_ placedPiece: PlacedPiece, store: PieceIdentifying, pieceID: Int) -> [SimulationEvent] {
        let rotationTime = 0.3
        let dropTimeSlow = 1.0
        let horizontalMoveTime = 0.15
        let fastDropWait = 0.75
        let dropTimeFast = 0.15

        let piece = store.getPiece(for: placedPiece.id)
        let initialRotation = piece.rotations[0]
        let finalRotationIdx = placedPiece.rotation
        let initialXPos = (size.width - initialRotation.size.width) / 2
        
        // first, rotate, dropping if a drop happens between rotations
        var currentYPos = 0
        var elapsedTime = 0.0
        var lastDropTime = 0.0
        var placements: [(PlacedPiece, Double)] = []
        for i in 0...finalRotationIdx {
            let nextPlacement = PlacedPiece(id: placedPiece.id, rotation: i, position: Point(x: initialXPos, y: currentYPos))
            placements.append((nextPlacement, elapsedTime))
            elapsedTime += rotationTime
            if elapsedTime - lastDropTime > dropTimeSlow {
                currentYPos += 1
                lastDropTime = lastDropTime + dropTimeSlow
                let dropPlacement = PlacedPiece(id: placedPiece.id, rotation: i, position: Point(x: initialXPos, y: currentYPos))
                placements.append((dropPlacement, lastDropTime))
            }
        }
        
        // then move horizontally, dropping if a drop happens
        let finalX = placedPiece.position.x
        for x in min(initialXPos, finalX)...max(initialXPos, finalX) {
            let nextPlacement = PlacedPiece(id: placedPiece.id, rotation: finalRotationIdx, position: Point(x: x, y: currentYPos))
            placements.append((nextPlacement, elapsedTime))
            elapsedTime += horizontalMoveTime
            if elapsedTime - lastDropTime > dropTimeSlow {
                currentYPos += 1
                lastDropTime = lastDropTime + dropTimeSlow
                let dropPlacement = PlacedPiece(id: placedPiece.id, rotation: finalRotationIdx, position: Point(x: x, y: currentYPos))
                placements.append((dropPlacement, lastDropTime))
            }
        }
        
        // finally, wait and then drop fast into the final position
        elapsedTime += fastDropWait
        if elapsedTime - lastDropTime > dropTimeSlow {
            currentYPos += 1
            lastDropTime = lastDropTime + dropTimeSlow
            let dropPlacement = PlacedPiece(id: placedPiece.id, rotation: finalRotationIdx, position: Point(x: finalX, y: currentYPos))
            placements.append((dropPlacement, lastDropTime))
        }
        while currentYPos < placedPiece.position.y {
            currentYPos += 1
            let dropPlacement = PlacedPiece(id: placedPiece.id, rotation: finalRotationIdx, position: Point(x: finalX, y: currentYPos))
            placements.append((dropPlacement, elapsedTime))
            elapsedTime += dropTimeFast
        }
        
        // add a drop at the end to cap it off
        placements.append((placedPiece, elapsedTime))
        return _moveEventsForKeyframes(placements, pieceID: pieceID)
    }
    
    private func _moveEventsForKeyframes(_ keyframes: [(PlacedPiece, Double)], pieceID: Int) -> [SimulationEvent] {
        var events: [SimulationEvent] = []
        
        var prevPlacement: PlacedPiece?
        var prevTime: Double?
        for (placement, time) in keyframes {
            if let prevPlacement, let prevTime {
                let moveEvent = MoveEvent(pieceID: pieceID, beforeState: prevPlacement, afterState: placement, duration: time - prevTime)
                events.append(.move(moveEvent))
            }
            prevPlacement = placement
            prevTime = time
        }
        
        return events
    }
}

