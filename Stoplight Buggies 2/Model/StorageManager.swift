//
//  StorageManager.swift
//  Stoplight Buggies 2
//
//  Created by Nick Cracchiolo on 9/12/18.
//  Copyright © 2018 Nick Cracchiolo. All rights reserved.
//

import Foundation

/// Class used to interact with NSKeyedArchiver and NSKeyedArchiver
class StorageManager {
    // Model Name used as final path component to store saved data
    private var modelName:String
    
    /// NSKeyedArchiver/Unarchiver file path
    private lazy var filePath:String = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return url?.appendingPathComponent(self.modelName).path ?? ""
    }()
    
    init(modelName name:String) {
        self.modelName = name
    }
    
    func load() -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
    }
    
    func save(object obj:Any) {
        NSKeyedArchiver.archiveRootObject(obj, toFile: self.filePath)
    }
}
