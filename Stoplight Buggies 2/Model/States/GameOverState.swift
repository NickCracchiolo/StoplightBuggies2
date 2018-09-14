//
//  GameOverState.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import GameplayKit

class GameOverState:GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}
