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
    
    final func getFrom(dictionary :NSDictionary) -> BlockGetMetaData {
        self.timeStamp = dictionary.objectForKey("timeStamp") as! Int
        self.difficulty = dictionary.objectForKey("difficulty") as! Int
        self.totalFee = dictionary.objectForKey("totalFee") as! Double
        self.id = dictionary.objectForKey("id") as! Int
        self.height = dictionary.objectForKey("height") as! Int
        
        return self
    }
}
