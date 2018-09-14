//
//  StoplightStateMachine.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import GameplayKit

class StoplightStateMachine: GKStateMachine {
    
    init(withScene scene:SKScene) {
        let paused = PausedState(withScene: scene)
        let red = RedState(withScene: scene)
        let yellow = YellowState(withScene: scene)
        let green = GreenState(withScene: scene)
        let gameOver = GameOverState()
        super.init(states: [paused, red, green, yellow, gameOver])
    }
    
    override func update(deltaTime sec: TimeInterval) {
        self.currentState?.update(deltaTime: sec)
    }
}
