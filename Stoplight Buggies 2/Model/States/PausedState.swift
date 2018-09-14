//
//  PausedState.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import GameplayKit

class PausedState:GKState {
    weak var scene:SKScene?
    var pauseScreen:PauseScreen?
    
    init(withScene s:SKScene) {
        self.scene = s
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        if let s = self.scene {
            let size = CGSize(width: s.frame.width / 2, height: s.frame.height / 2)
            self.pauseScreen = PauseScreen(size: size, z:5.0)
            self.pauseScreen?.position = CGPoint(x: s.frame.midX, y: s.frame.midY)
            s.addChild(self.pauseScreen!)
        }
    }
    override func willExit(to nextState: GKState) {
        pauseScreen?.removeFromParent()
    }
}
