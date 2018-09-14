//
//  MainMenuViewController.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MainMenuViewController: UIViewController {
    // Manager to access local storage using NSKeyedArchiver and NSKeyedUnarchiver
    let storageManager = StorageManager(modelName: "Player")
    var player:Player!
    lazy var networking:MultiplayerNetworking = MultiplayerNetworking(withPlayer: self.player)
    var joinAlert:UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let p = storageManager.load() as? Player {
            self.player = p
        } else {
            newPlayerAlert()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePlayerSegue" {
            if let vc = segue.destination as? GameViewController {
                vc.storageManager = self.storageManager
                vc.player = self.player
            }
        } else if segue.identifier == "CreateMultiplayerGameSegue" {
            if let vc = segue.destination as? CreateGameViewController {
                vc.networking = self.networking
                vc.storageManager = self.storageManager
                vc.player = self.player
            }
        }
    }
    
    @IBAction func multiplayerButtonClicked(_ sender:UIButton) {
        multiplayerAlert(sender)
    }
    
    private func newPlayerAlert() {
        let alert = UIAlertController(title: "New Player", message: "Enter your name.", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "Enter your name here."
        }
        let begin = UIAlertAction(title: "Begin Game", style: .default) { [weak self] (action) in
            guard let self = self else {
                print("Self no longer exists")
                return
            }
            if let field = alert.textFields?.first {
                let player = Player(name: field.text ?? "Player")
                self.storageManager.save(object: player)
            }
        }
        alert.addAction(begin)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func multiplayerAlert(_ sender:UIButton) {
        let alert = UIAlertController(title: "Multiplayer Option", message: nil, preferredStyle: .actionSheet)
        let create = UIAlertAction(title: "Create Game", style: .default) { (action) in
            self.performSegue(withIdentifier: "CreateMultiplayerGameSegue", sender: nil)
        }
        let join = UIAlertAction(title: "Join Game", style: .default) { (action) in
            self.beginAdvertising()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(create)
        alert.addAction(join)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceRect = sender.frame
        alert.popoverPresentationController?.sourceView = sender
        self.present(alert, animated: true, completion: nil)
    }
    
    private func beginAdvertising() {
        networking.delegate = self
        networking.createSession()
        networking.advertise()
        joinAlert = UIAlertController(title: "Waiting for invite...", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (action) in
            guard let self = self else { return }
            self.networking.stopAdvertising()
            self.networking.session?.disconnect()
        }
        joinAlert!.addAction(cancel)
        self.present(joinAlert!, animated: true, completion: nil)
    }
}

extension MainMenuViewController: MultiplayerNetworkingDelegate {
    func foundPeer(withID id: MCPeerID, info: [String : String]?) {
        print("Found Peer")
    }
    
    func peerLeft(withID id: MCPeerID) {
        print("Peer Left")
    }
    
    func recievedInvite(fromPeer peer: MCPeerID, inviteHandler: @escaping (Bool, MCSession?) -> Void) {
        joinAlert?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "Game Invite", message: "\(peer.displayName) would like to invite you to play", preferredStyle: .alert)
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { [weak self] (action) in
                guard let self = self else {
                    inviteHandler(false, nil)
                    return
                }
                inviteHandler(true, self.networking.session)
            })
            let decline = UIAlertAction(title: "Decline", style: .cancel, handler: { (action) in
                inviteHandler(false, nil)
            })
            alert.addAction(accept)
            alert.addAction(decline)
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func connected(withPeer peer: MCPeerID) {
        print("Connected with: \(peer.displayName)")
    }
    
    func networkFailure(withError error: Error) {
        joinAlert?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "Networking Error", message: "Sorry, there was an error looking for a match, please check that at least bluetooth is enabled.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        })
    }
}
