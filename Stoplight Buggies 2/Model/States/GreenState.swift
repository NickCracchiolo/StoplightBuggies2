//
//  GreenState.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import GameplayKit

class GreenState:LightState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is YellowState.Type || stateClass is PausedState.Type {
            return true
        }
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        self.time = 100
        if let s = scene {
            s.backgroundColor = .green
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.time -= 1
        if time <= 0 {
            self.stateMachine?.enter(YellowState.self)
        }
    }
}
