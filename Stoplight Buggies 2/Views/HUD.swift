//
//  HUD.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import SpriteKit

class HUD {
    weak var scene:SKScene?
    var pauseButton = SKSpriteNode(imageNamed: "PauseButton")
    var timeLabel = SKLabelNode(text: "0.00")
    private var z:CGFloat
    
    init(withScene s:SKScene, zPosition:CGFloat) {
        self.scene = s
        self.z = zPosition
    }
    
    func present() {
        self.addPauseButton()
        self.addTimeLabel()
    }
    
    func updateTimeLabel(withTime time:CFTimeInterval) {
        //DispatchQueue.main.async {
        self.timeLabel.text = String(format: "%0.2f", time)
        //}
    }
    
    private func addPauseButton() {
        guard let s = self.scene else { return }
        pauseButton.name = Button.pause
        pauseButton.zPosition = z
        let x:CGFloat = pauseButton.frame.width
        let y:CGFloat = s.frame.maxY - pauseButton.frame.height
        pauseButton.position = CGPoint(x: x, y: y)
        s.addChild(pauseButton)
    }
    
    private func addTimeLabel() {
        guard let s = self.scene else { return }
        timeLabel.name = "TimeLabel"
        timeLabel.zPosition = z
        let x:CGFloat = s.frame.midX
        let y:CGFloat = s.frame.maxY * 0.90
        timeLabel.position = CGPoint(x: x, y: y)
        s.addChild(timeLabel)
    }
}
