//
//  MultiplayerGameSegue.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/14/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import SpriteKit
import GameplayKit
import QuartzCore
import MultipeerConnectivity

class MultiplayerGameScene: SKScene {
    private enum Positions {
        case background
        case racetrack
        case line
        case car
        case hud
        case pause
        
        func z() -> CGFloat {
            switch self {
            case .background:
                return 0.0
            case .racetrack:
                return 1.0
            case .line:
                return 2.0
            case .car:
                return 3.0
            case .hud:
                return 4.0
            case .pause:
                return 5.0
            }
        }
    }
    
    
    lazy var stateMachine = StoplightStateMachine(withScene: self)
    var networking:MultiplayerNetworking!
    var storageManager:StorageManager!
    var player:Player!
    lazy var trackWidth:CGFloat = self.frame.width * 0.75
    lazy var startPosition:CGPoint = CGPoint(x: self.frame.midX, y: self.frame.midY / 4)
    var displayLink: CADisplayLink!
    var time: CFTimeInterval!
    var lastState:AnyClass?
    var resets:Int = 0
    
    lazy var car:SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: Car.green.imageName())
        node.zPosition = Positions.car.z()
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: node.size.height - 10))
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.contactTestBitMask = node.physicsBody!.collisionBitMask
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = CGPoint(x: startPosition.x, y: startPosition.y - node.frame.height)
        node.name = "Player"
        return node
    }()
    
    lazy var racetrack:SKSpriteNode = {
        let node = SKSpriteNode(color: .gray, size: CGSize(width: trackWidth, height: self.frame.height))
        node.zPosition = Positions.racetrack.z()
        node.anchorPoint = CGPoint(x: 0.5, y: 0)
        node.position = CGPoint(x: self.frame.midX, y: 0)
        node.name = "Racetrack"
        return node
    }()
    
    lazy var startingLine:SKSpriteNode = {
        let node = SKSpriteNode(color: .green, size: CGSize(width: trackWidth, height: 40))
        node.zPosition = Positions.racetrack.z()
        node.anchorPoint = CGPoint(x: 0.5, y: 0)
        node.position = startPosition
        node.name = "StartingLine"
        return node
    }()
    
    lazy var finishLine:SKSpriteNode = {
        let node = SKSpriteNode(color: .white, size: CGSize(width: trackWidth, height: 40))
        node.zPosition = Positions.racetrack.z()
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: 5))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.affectedByGravity = false
        node.anchorPoint = CGPoint(x: 0.5, y: 0)
        node.position = CGPoint(x: self.frame.midX, y: self.frame.height * 0.75)
        node.name = "FinishLine"
        return node
    }()
    
    lazy var lanes:[SKSpriteNode] = {
        let count = self.networking.session?.connectedPeers.count ?? 2
        var nodes:[SKSpriteNode] = []
        let size = CGSize(width: 10, height: self.frame.height)
        for i in 0..<(count - 1) {
            var x:CGFloat = self.frame.midX
            if (count - 1) == 3 {
                x = self.frame.midX + ((trackWidth / 4.0) * CGFloat(pow(-1.0, Double(i + 1))))
            } else {
                x = (self.frame.midX / (trackWidth / 2.0)) + ((trackWidth / 2.0) * CGFloat(i + 1))
            }
            let n = SKSpriteNode(color: .yellow, size: size)
            n.zPosition = Positions.racetrack.z()
            n.anchorPoint = CGPoint(x: 0.5, y: 0)
            n.position = CGPoint(x: x, y: 0)
            nodes.append(n)
        }
        return nodes
    }()
    
    lazy var hud = HUD(withScene: self, zPosition: Positions.hud.z())
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        networking.delegate = self
        self.physicsWorld.contactDelegate = self
        self.addChild(self.racetrack)
        self.addChild(self.finishLine)
        self.addChild(self.startingLine)
        self.addChild(self.car)
        self.hud.present()
        self.displayLink = CADisplayLink(target: self, selector: #selector(timerUpdated(_:)))
        self.displayLink.isPaused = true;
        self.displayLink.add(to: RunLoop.main, forMode: .common)
        self.time = self.displayLink.timestamp
        
        stateMachine.enter(GreenState.self)
        displayLink.isPaused = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        self.stateMachine.update(deltaTime: currentTime)
        if networking.isHost {
            if let state = self.stateMachine.currentState {
                if state is RedState {
                    networking.sendGameState(state: GameState.red)
                } else if state is YellowState {
                    networking.sendGameState(state: GameState.yellow)
                } else if state is GreenState {
                    networking.sendGameState(state: GameState.green)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //// MARK: Touch Helper Method for individual points
    func touchDown(atPoint pos : CGPoint) {
        let nodes = self.nodes(at: pos)
        if let state = self.stateMachine.currentState {
            if state is PausedState {
                return
            } else if state is RedState {
                self.resetCar()
            } else {
                self.moveCar()
            }
            if let node = nodes.first {
                if node.name == Button.pause {
                    self.stopCar()
                    self.lastState = state.classForCoder
                    self.displayLink.isPaused = true
                    self.stateMachine.enter(PausedState.self)
                } else if node.name == Button.resume {
                    self.stateMachine.enter(self.lastState ?? RedState.self)
                    self.displayLink.isPaused = false
                }
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let state = self.stateMachine.currentState {
            if state is PausedState {
                self.stopCar()
                return
            } else if state is RedState {
                self.resetCar()
            } else {
                self.moveCar()
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let state = self.stateMachine.currentState {
            if state is PausedState {
                return
            } else  {
                stopCar()
            }
        }
    }
    
    
    //// MARK: Stopclock Functions
    @objc func timerUpdated(_ sender:CADisplayLink) {
        self.time = self.time + self.displayLink.duration
        self.hud.updateTimeLabel(withTime: self.time)
    }
    
    //// MARK: Car Movement Functions
    func moveCar() {
        let action = SKAction.run {
            self.car.physicsBody?.velocity = CGVector(dx: 0, dy: 60)
        }
        self.run(action)
    }
    
    func stopCar() {
        let action = SKAction.run {
            self.car.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
        self.run(action)
    }
    
    func resetCar() {
        let action = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.resets += 1
            self.car.position = CGPoint(x: self.startPosition.x, y: self.startPosition.y - self.car.frame.height)
        }
        self.run(action)
    }
}

extension MultiplayerGameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        self.displayLink.invalidate()
        self.stateMachine.enter(GameOverState.self)
        print("Total Time: " + String(format: "%0.2f", self.time))
        print("Number of resets: \(self.resets)")
//        let game = Game(id: self.player.games.count, resets: self.resets, time: self.time, car: Car.green.imageName())
//        self.player.games.append(game)
//        self.storageManager.save(object: self.player)
    }
}

extension MultiplayerGameScene: MultiplayerNetworkingDelegate {
    func foundPeer(withID id: MCPeerID, info: [String : String]?) {
        <#code#>
    }
    
    func peerLeft(withID id: MCPeerID) {
        <#code#>
    }
    
    func recievedInvite(fromPeer peer: MCPeerID, inviteHandler: @escaping (Bool, MCSession?) -> Void) {
        <#code#>
    }
    
    func connected(withPeer peer: MCPeerID) {
        <#code#>
    }
    
    func networkFailure(withError error: Error) {
        <#code#>
    }
    
    
}
