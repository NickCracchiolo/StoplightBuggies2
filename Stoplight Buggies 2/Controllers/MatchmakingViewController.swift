//
//  MatchmakingViewController.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MatchmakingViewController: UITableViewController {
    var peers:[MCPeerID] = []
    var player:Player!
    lazy var networking:MultiplayerNetworking = MultiplayerNetworking(withPlayer: self.player)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networking.createSession(withDelegate: self)
        networking.browse(withDelegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            if let vc = segue.destination as? MultiplayerGameViewController {
                
            }
        }
    }
    
    private func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MatchmakingViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        networking.connect(toPeer: peers[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as? GameCell {
            cell.nameLabel.text = peers[indexPath.row].displayName
            return cell
        }
        return UITableViewCell()
    }
}

extension MatchmakingViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found Peer!")
        peers.append(peerID)
        reload()
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peers.removeAll { (id) -> Bool in
            return id == peerID
        }
        reload()
        
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension MatchmakingViewController: MCSessionDelegate {
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
