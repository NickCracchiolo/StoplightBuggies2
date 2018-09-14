//
//  MainMenuViewController.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    // Manager to access local storage using NSKeyedArchiver and NSKeyedUnarchiver
    let storageManager = StorageManager(modelName: "Player")
    var player:Player!
    
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
                vc.storageManager = self.storageManager
                vc.player = self.player
            }
        } else if segue.identifier == "JoinMultiplayerGameSegue" {
            if let vc = segue.destination as? MatchmakingViewController {
                //vc.storageManager = self.storageManager
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
            self.performSegue(withIdentifier: "JoinMultiplayerGameSegue", sender: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(create)
        alert.addAction(join)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceRect = sender.frame
        alert.popoverPresentationController?.sourceView = sender
        self.present(alert, animated: true, completion: nil)
    }
}
