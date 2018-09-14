//
//  PauseScreen.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import SpriteKit

class PauseScreen: SKNode {
    var shapeNode:SKShapeNode
    
    init(size:CGSize, z:CGFloat) {
        self.shapeNode = SKShapeNode(rectOf: size, cornerRadius: 5)
        shapeNode.fillColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        shapeNode.zPosition = z
        super.init()
        self.addChild(shapeNode)
        addLabels(labels: [("Resume",Button.resume), ("Quit", Button.quit)])
    }
    required init?(coder aDecoder: NSCoder) {
        self.shapeNode = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: CGSize.zero))
        super.init(coder: aDecoder)
    }
    /// Add a labels to the Pause Screen. Format: [(Label String, Label Name)]
    func addLabels(labels:[(String, String)]) {
        let x = shapeNode.frame.midX
        var y = shapeNode.frame.maxY
        let offset:CGFloat = 0.0
        for l in labels {
            addLabel(toNode: shapeNode, withText: l.0, name: l.1, atX: x, atY: &y)
            y -= offset
        }
    }
    func addLabel(toNode node:SKNode, withText text:String, name:String, atX x:CGFloat, atY y:inout CGFloat) {
        let label = SKLabelNode(text: text)
        y -= (label.frame.height + 15)
        label.position = CGPoint(x: x, y: y)
        label.name = name
        node.addChild(label)
    }
}
