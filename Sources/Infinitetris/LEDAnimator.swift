//
//  LEDAnimator.swift
//  
//
//  Created by Michael Brandt on 4/6/23.
//

import SwiftLED
import TetrominoCore
import Dispatch
import Foundation

class LEDAnimator: Animator {
    var requiresPrecomputation: Bool = false
    
    private var displayBoard: DisplayBoard?
    private var matrix: LEDMatrix?
    private var canvas: LEDCanvas?
    private var offscreenCanvas: LEDCanvas?
    private var previousFrameDuration = 0.0
    
    func prepare(dimensions: TetrominoCore.Size, allEvents: [SimulationEvent]?) {
        displayBoard = DisplayBoard(dimensions: dimensions)
        
        var options = MatrixOptions()
        options.hardware_mapping = "adafruit-hat-pwm"
        options.rows = 32
        options.cols = 64
        options.disable_hardware_pulsing = true
        options.limit_refresh_rate_hz = 60
        
        var runtimeOptions = RuntimeOptions()
        runtimeOptions.gpio_slowdown = 4
        
        let matrix = LEDMatrix(options: options, runtimeOptions: runtimeOptions)
        
        guard let canvas = matrix.getCanvas() else {
            preconditionFailure("Failed to get canvas")
        }
        canvas.clear()
        self.canvas = canvas
        
        guard let offscreenCanvas = matrix.createOffscreenCanvas() else {
            preconditionFailure("Failed to create offscreen canvas")
        }
        self.offscreenCanvas = offscreenCanvas
    }
    
    
    
    func animateEvent(_ event: SimulationEvent, completion: @escaping () -> Void) {
        switch event {
        case .appear(let appearEvent):
            _updateForAppear(appearEvent)
            _addFrame(duration: appearEvent.duration, completion: completion)
        case .move(let moveEvent):
            _updateForMove(moveEvent)
            _addFrame(duration: moveEvent.duration, completion: completion)
        case .clear(let clearEvent):
            _updateForClear(clearEvent)
            _addFrame(duration: 0.5, completion: completion)
        }
    }
    
    private func _updateForAppear(_ appear: AppearEvent) {
        displayBoard!.updateForAppear(appear)
    }
    
    private func _updateForMove(_ move: MoveEvent) {
        displayBoard!.updateForMove(move)
    }
    
    private func _updateForClear(_ clear: ClearEvent) {
        displayBoard!.updateForClear(clear)
    }
    
    private func _addFrame(duration: Double, completion: @escaping ()->Void) {
        let startTime = ProcessInfo.processInfo.systemUptime
        for py in 0..<64 {
            for px in 0..<32 {
                let color: DisplayColor?
                if px >= 1 && px < 31 && py >= 4 {
                    let boardX = (px - 1) / 3
                    let boardY = (py - 4) / 3
                    color = displayBoard!.getColor(at: Point(x: boardX, y: boardY))
                } else {
                    color = nil
                }
                
                // flip for board coordinates
                let pixel = Pixel(x: Int32(py), y: Int32(px))
                let canvasColor = Color(r: color?.r ?? 0, g: color?.g ?? 0, b: color?.b ?? 0)
                offscreenCanvas!.setPixel(pixel, color: canvasColor)
            }
        }
        
        let frameCompletion: ()->Void = { [self] in
            let oldOffscreen = offscreenCanvas
            offscreenCanvas = matrix!.swapCanvasOnVSync(offscreenCanvas!)
            canvas = oldOffscreen
            completion()
        }
        
        let prepTime = ProcessInfo.processInfo.systemUptime - startTime
        let targetSeconds = previousFrameDuration - prepTime
        previousFrameDuration = duration
        if targetSeconds > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + targetSeconds) {
                frameCompletion()
            }
        } else {
            DispatchQueue.main.async {
                frameCompletion()
            }
        }
    }
    
    func finalize() {
        canvas = nil
        offscreenCanvas = nil
        matrix = nil
    }
    
    
}
