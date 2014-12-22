//
//  ServerTableVC.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 12.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class ServerTableVC: UITableViewController , UITableViewDataSource, UITableViewDelegate
{

    let fileManager : plistFileManager = plistFileManager()
    var servers : NSArray = NSArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        servers = fileManager.getServers()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return servers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : ServerViewCell = self.tableView.dequeueReusableCellWithIdentifier("serverCell") as ServerViewCell
        var cellData  : NSDictionary = servers[indexPath.row] as NSDictionary
        cell.serverName.text = cellData.objectForKey("name") as NSString
        cell.serverAddress.text = cellData.objectForKey("address") as NSString
        return cell
    }
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
    }
}
