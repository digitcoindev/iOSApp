//
//  plistFileManager.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 12.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class plistFileManager: NSObject
{
    var fileManager  : NSFileManager = NSFileManager()
    var deviceData : NSMutableDictionary = NSMutableDictionary()
    var uiData : NSMutableDictionary = NSMutableDictionary()
    
    override init()
    {
        super.init()
        
        deviceData = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Sourses", ofType: "plist")!)!
        uiData = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("UIConfig", ofType: "plist")!)!
     }
    
    //GENERAL
    
    func commit()
    {
        deviceData.writeToFile(NSBundle.mainBundle().pathForResource("Sourses", ofType: "plist")!, atomically: true)
        uiData.writeToFile(NSBundle.mainBundle().pathForResource("UIConfig", ofType: "plist")!, atomically: true)
    }
    
    //UIConfig
    
    func getMenuItems() -> NSMutableArray
    {
        return uiData.objectForKey("mainMenu") as NSMutableArray
    }
    
}
