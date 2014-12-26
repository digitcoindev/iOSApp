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
    var menuItems : NSArray = NSArray()
    var menu : NSArray = NSArray()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        servers = dataManager.getServers()
        menuItems = deviceManager.getMenuItems()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    func selectedPage(notification: NSNotification)
    {
        //Action take on Notification
        println("ser good")
    }
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
        var pageIndex = indexPath.row
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:pageIndex )
    }
}

