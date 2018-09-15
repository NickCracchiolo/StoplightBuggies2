//
//  MultiplayerGameViewController.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MultiplayerGameViewController: UIViewController {
    
    // Manager to access local storage using NSKeyedArchiver and NSKeyedUnarchiver
    var storageManager:StorageManager!
    var networking:MultiplayerNetworking!
    var player:Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MultiplayerGameScene") as? MultiplayerGameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill
                scene.player = self.player
                scene.storageManager = self.storageManager
                scene.networking = self.networking
                scene.anchorPoint = CGPoint(x: 0, y: 0)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
