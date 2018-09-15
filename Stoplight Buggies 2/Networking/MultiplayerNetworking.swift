//
//  MultiplayerNetworking.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import MultipeerConnectivity

protocol MultiplayerNetworkingDelegate: class {
    func foundPeer(withID id:MCPeerID, info: [String:String]?)
    func peerLeft(withID id:MCPeerID)
    func recievedInvite(fromPeer peer:MCPeerID, inviteHandler: @escaping (Bool, MCSession?) -> Void)
    func connected(withPeer peer:MCPeerID)
    func networkFailure(withError error:Error)
}

class MultiplayerNetworking:NSObject {
    weak var delegate:MultiplayerNetworkingDelegate?
    var session:MCSession?
    private var advertiser:MCNearbyServiceAdvertiser?
    private var browser:MCNearbyServiceBrowser?
    private var player:Player
    private let peer:MCPeerID
    private let serviceType = "slb-game"
    var isHost:Bool = false
    
    init(withPlayer p:Player) {
        self.player = p
        self.peer = MCPeerID(displayName: p.name)
    }
    
    func createSession() {
        self.session = MCSession(peer: self.peer)
        self.session!.delegate = self
        if self.session?.myPeerID != peer {
            print("Peers not equal")
        }
    }
    
    func browse() {
        self.browser = MCNearbyServiceBrowser(peer: self.peer, serviceType: self.serviceType)
        self.browser!.delegate = self
        self.browser!.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        self.browser?.stopBrowsingForPeers()
    }
    
    func advertise() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peer, discoveryInfo: nil, serviceType: serviceType)
        self.advertiser!.delegate = self
        self.advertiser!.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        self.advertiser?.stopAdvertisingPeer()
    }
    
    func invite(peer peerID:MCPeerID) {
        if let b = self.browser, let s = self.session {
            b.invitePeer(peerID, to: s, withContext: nil, timeout: 30)
        }
    }
    
    func sendGameState(state:GameState) {
        var packet = StatePacket.init(state: state.rawValue)
        let data = Data(bytes: &packet, count: 1)
        do {
            try session?.send(data, toPeers: session?.connectedPeers ?? [], with: .unreliable)
        } catch {
            print("Error sending state")
        }
    }
    
}

extension MultiplayerNetworking: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Session did change state")
        switch state {
        case .notConnected:
            print("Not Connected")
        case .connecting:
            print("Connecting")
        case .connected:
            print("Connected")
            self.delegate?.connected(withPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Session did recieve data from \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Session did recieve stream: \(streamName) from \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Session did start receieving resource: \(resourceName) from \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Session did finish receiving resource: \(resourceName) from \(peerID.displayName)")
    }
}

extension MultiplayerNetworking: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.delegate?.recievedInvite(fromPeer: peerID, inviteHandler:invitationHandler)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        self.delegate?.networkFailure(withError: error)
    }
}

extension MultiplayerNetworking: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.delegate?.foundPeer(withID: peerID, info: info)
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.delegate?.peerLeft(withID: peerID)
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        self.delegate?.networkFailure(withError: error)
    }
}
