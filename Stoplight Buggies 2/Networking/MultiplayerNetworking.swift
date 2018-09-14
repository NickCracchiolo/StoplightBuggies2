//
//  MultiplayerNetworking.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import MultipeerConnectivity

class MultiplayerNetworking {
    private var session:MCSession?
    private var advertiser:MCNearbyServiceAdvertiser?
    private var browser:MCNearbyServiceBrowser?
    private var player:Player
    private var peer:MCPeerID
    private let serviceType = "slb-game"
    
    init(withPlayer p:Player) {
        self.player = p
        self.peer = MCPeerID(displayName: p.name)
    }
    
    func createSession(withDelegate delegate:MCSessionDelegate) {
        let peer = MCPeerID(displayName: self.player.name)
        self.session = MCSession(peer: peer)
        self.session!.delegate = delegate
    }
    
    func browse(withDelegate delegate:MCNearbyServiceBrowserDelegate) {
        self.browser = MCNearbyServiceBrowser(peer: self.peer, serviceType: self.serviceType)
        self.browser!.delegate = delegate
        self.browser!.startBrowsingForPeers()
    }
    
    func advertise(withDelegate delegate:MCNearbyServiceAdvertiserDelegate) {
        self.advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        self.advertiser!.delegate = delegate
        self.advertiser!.startAdvertisingPeer()
    }
    
    func connect(toPeer peerID:MCPeerID) {
        if let b = self.browser, let s = self.session {
            b.invitePeer(peerID, to: s, withContext: nil, timeout: 30)
        }
    }
    
    func sendGameState(state:AnyClass) {
        if state is GreenState.Type {
            self.sendState(state: "green")
        } else if state is YellowState.Type {
            self.sendState(state: "yellow")
        } else if state is RedState.Type {
            self.sendState(state: "red")
        }
    }
    
    private func stream() {
        
    }
    
    private func sendState(state: String, object: AnyObject? = nil) {
        guard let s = session else {
            return
        }
        var rootObject: [String: Any] = ["state": state]
        if let object = object {
            rootObject["object"] = object
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: rootObject)
        do {
            try s.send(data, toPeers: s.connectedPeers, with: .reliable)
        } catch {
            print("Error sending state to peers")
        }
    }
    
}
