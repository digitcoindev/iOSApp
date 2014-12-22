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
    let fileManager  : NSFileManager = NSFileManager()
    var deviceData : NSMutableDictionary = NSMutableDictionary()
    var uiData : NSMutableDictionary = NSMutableDictionary()
    
    override init()
    {
        super.init()
        
        deviceData = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Sourses", ofType: "plist")!)
        uiData = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("UIConfig", ofType: "plist")!)
     }
    
    //SERVERS
    
    func currentServer() -> NSMutableDictionary
    {
        return deviceData.objectForKey("currentServer") as NSMutableDictionary
    }
    
    func getServers() ->NSMutableArray
    {
        return deviceData.objectForKey("servers") as NSMutableArray
    }
    
    func addServer(name: String ,address: String ,port: String)
    {
        var servers : NSMutableArray = deviceData.objectForKey("servers") as NSMutableArray
        var dict = ["name":name,"address": address , "port": port ]
        
        servers.addObject(dict)
        commit()
    }
    
    //ACCOUNTS
    
    func addAcounnt(name :String, email : String , password : String )
    {
        var accounts : NSMutableArray = deviceData.objectForKey("wallets") as NSMutableArray
        var dict = ["login": name , "password" : password ,"mail":"address@i.ua" ,"picture" : "/documents/user1/picture1.png"]
        
        accounts.addObject(dict)
        commit()
    }
    
    func getAccounts() ->NSMutableArray
    {
        return deviceData.objectForKey("wallets") as NSMutableArray
    }
    
    //GENERAL
    
    func commit()
    {
         deviceData.writeToFile(NSBundle.mainBundle().pathForResource("Sourses", ofType: "plist")!, atomically: true)
    }
    
    //UIConfig
    
    func getMenuItems() -> NSMutableArray
    {
        return uiData.objectForKey("mainMenu") as NSMutableArray
    }
    
}
