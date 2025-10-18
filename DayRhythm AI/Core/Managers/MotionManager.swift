//
//  MotionManager.swift
//  DayRhythm AI
//
//  Created by kartikay on 19/10/25.
//

import CoreMotion
import Combine


class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    
    init() {
        startMotionUpdates()
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            
            let rawPitch = motion.attitude.pitch * 0.5
            let rawRoll = motion.attitude.roll * 0.5
            
            self?.pitch = max(-0.15, min(0.15, rawPitch))
            self?.roll = max(-0.15, min(0.15, rawRoll))
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
