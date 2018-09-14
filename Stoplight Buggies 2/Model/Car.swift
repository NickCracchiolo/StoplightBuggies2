//
//  Car.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import Foundation

enum Car {
    case green
    
    func imageName() -> String {
        switch self {
        case .green:
            return "car1"
        }
    }
}
