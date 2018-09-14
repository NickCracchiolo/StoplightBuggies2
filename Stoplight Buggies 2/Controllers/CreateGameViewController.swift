//
//  CreateGameViewController.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/14/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class CreateGameViewController: UIViewController {
    var storageManager:StorageManager!
    var player:Player!
    lazy var networking = MultiplayerNetworking(withPlayer: self.player)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networking.createSession(withDelegate: self)
        networking.advertise(withDelegate: self)
    }
}

extension CreateGameViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invitation from: \(peerID.displayName)")
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CreateGameViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Session did change state: \(state)")
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
