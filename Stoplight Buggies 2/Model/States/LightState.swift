//
//  LightState.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import GameplayKit

class LightState:GKState {
    var time:TimeInterval = 0
    weak var scene:SKScene?
    
    init(withScene s:SKScene) {
        self.scene = s
    }
}
