//
//  Game.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import Foundation

class Game:NSObject, NSCoding {
    // Struct for keys for easy access and reuse
    private struct DecoderKeys {
        static let id = "id"
        static let resets = "resets"
        static let time = "time"
        static let car = "car"
    }
    
    var id:Int
    var resets:Int
    var time:CFTimeInterval
    var car:String
    
    init(id:Int, resets:Int, time:CFTimeInterval, car:String) {
        self.id = id
        self.resets = resets
        self.time = time
        self.car = car
        super.init()
    }
    
    //// MARK: NSCoding Methods
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: DecoderKeys.id)
        self.resets = aDecoder.decodeInteger(forKey: DecoderKeys.resets)
        self.time = aDecoder.decodeDouble(forKey: DecoderKeys.time)
        self.car = aDecoder.decodeObject(forKey: DecoderKeys.car) as? String ?? Car.green.imageName()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: DecoderKeys.id)
        aCoder.encode(self.resets, forKey: DecoderKeys.resets)
        aCoder.encode(self.time, forKey: DecoderKeys.time)
        aCoder.encode(self.car, forKey: DecoderKeys.car)
    }
}
