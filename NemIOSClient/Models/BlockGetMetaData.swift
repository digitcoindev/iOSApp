//
//  BlockGetMetaData.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 29.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class BlockGetMetaData: NSObject {
    var timeStamp :Int = -1
    var difficulty :Int = -1
    var totalFee :Double = -1
    var id :Int = -1
    var height :Int = -1
    
    final func getFrom(_ dictionary :NSDictionary) -> BlockGetMetaData {
        self.timeStamp = dictionary.object(forKey: "timeStamp") as! Int
        self.difficulty = dictionary.object(forKey: "difficulty") as! Int
        self.totalFee = dictionary.object(forKey: "totalFee") as! Double
        self.id = dictionary.object(forKey: "id") as! Int
        self.height = dictionary.object(forKey: "height") as! Int
        
        return self
    }
}
