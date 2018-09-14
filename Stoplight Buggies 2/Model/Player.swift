//
//  Player.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import Foundation

/// Player object used to store all of the local player's info and statistics
class Player:  NSObject, NSCoding {
    // Struct for keys for easy access and reuse
    private struct DecoderKeys {
        static let name = "name"
        static let games = "games"
        static let cars = "cars"
    }
    
    var name:String
    var games:[Game]
    var cars:[String]
    
    init(name:String) {
        self.name = name
        self.games = []
        self.cars = ["car"]
        super.init()
    }
    
    //// MARK: NSCoding Methods
    required init?(coder aDecoder: NSCoder) {
        if let n = aDecoder.decodeObject(forKey: DecoderKeys.name) as? String {
            self.name = n
        } else {
            self.name = "Player"
        }
        self.games = aDecoder.decodeObject(forKey: DecoderKeys.games) as? [Game] ?? []
        self.cars = aDecoder.decodeObject(forKey: DecoderKeys.cars) as? [String] ?? ["car1"]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: DecoderKeys.name)
        aCoder.encode(self.games, forKey: DecoderKeys.games)
        aCoder.encode(self.cars, forKey: DecoderKeys.cars)
    }
}
