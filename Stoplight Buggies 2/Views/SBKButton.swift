//
//  SBKButton.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/13/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import UIKit

class SBKButton: UIButton {    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width

    }
}
