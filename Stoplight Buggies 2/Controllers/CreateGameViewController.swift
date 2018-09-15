//
//  CreateGameViewController.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/14/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class CreateGameViewController: UITableViewController {
    var storageManager:StorageManager!
    var player:Player!
    var players:[MCPeerID] = []
    var peers:[MCPeerID] = []
    var networking:MultiplayerNetworking!
    let sectionHeaders:[String] = ["Accepted Players", "Players to Invite"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButtons()
        networking.delegate = self
        networking.createSession()
        networking.browse()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            if let vc = segue.destination as? MultiplayerGameViewController {
                vc.networking = self.networking
                vc.player = self.player
                vc.storageManager = self.storageManager
            }
        }
    }
    
    private func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    private func addBarButtons() {
        let playButton = UIBarButtonItem(title: "Play", style: .done, target: self, action: #selector(beginGame(_:)))
        self.navigationItem.rightBarButtonItem = playButton
    }
    
    @objc func beginGame(_ sender:UIBarButtonItem) {
        if (networking.session?.connectedPeers.count ?? 0) > 1 {
            self.performSegue(withIdentifier: "MultiplayerGameSegue", sender: nil)
        }
    }
}

extension CreateGameViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            networking.invite(peer: peers[indexPath.row])
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return players.count
        default:
            return peers.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as? GameCell {
            switch indexPath.section {
            case 0:
                cell.nameLabel.text = players[indexPath.row].displayName
            default:
                cell.nameLabel.text = peers[indexPath.row].displayName
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension CreateGameViewController: MultiplayerNetworkingDelegate {
    func foundPeer(withID id: MCPeerID, info: [String : String]?) {
        print("Found Peer")
        peers.append(id)
        reload()
    }
    
    func peerLeft(withID id: MCPeerID) {
        print("Peer Left")
        peers.removeAll { (id) -> Bool in
            return id == id
        }
        reload()
    }
    
    func recievedInvite(fromPeer peer: MCPeerID, inviteHandler: @escaping (Bool, MCSession?) -> Void) {

    }
    
    func connected(withPeer peer: MCPeerID) {
        print("Connected with: \(peer.displayName)")
        self.players.append(peer)
        self.peers.removeAll { (id) -> Bool in
            return id == peer
        }
        reload()
    }
    
    func networkFailure(withError error: Error) {
        self.navigationController?.popViewController(animated: true)
    }
}
