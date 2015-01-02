//
//  MainMenuVC.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 19.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class MainMenuVC:  UITableViewController , UITableViewDataSource, UITableViewDelegate
{
    
    let dataManager : CoreDataManager = CoreDataManager()
    let deviceManager : plistFileManager = plistFileManager()
    
    var servers : NSArray = NSArray()
    var menuItems : NSMutableArray = NSMutableArray()
    var menu : NSArray = NSArray()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        servers = dataManager.getServers()
        menu = deviceManager.getMenuItems()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        for item in menu
        {
            if(State.currentWallet != -1)
            {
                
                switch (item as String)
                {
                    
                case "Registration" ,"Login" , "Servers" :
                    break
                    
                default:
                    menuItems.addObject(item)
                    
                }
            }
            else
            {
                switch (item as String)
                {
                    
                case "Registration" ,"Login" , "Servers" :
                    menuItems.addObject(item)
                    
                default:
                    break
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : MainViewCell = self.tableView.dequeueReusableCellWithIdentifier("mainCell") as MainViewCell
        cell.title.text = menuItems.objectAtIndex(indexPath.row) as? String
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var page: String  = menuItems.objectAtIndex(indexPath.row) as String
        
        switch (page)
        {
        case "Registration":
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToRegistrationVC )
            
        case "Login":
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
            
        case "Servers":
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerVC )
            
        case "Dashboard":
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToDashboard )
            
        default:
            print("")
            
        }
    }
}

