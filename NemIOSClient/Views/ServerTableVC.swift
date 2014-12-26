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

    let dataManager : CoreDataManager = CoreDataManager()
    var servers : NSArray = NSArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        servers = dataManager.getServers()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero) //[[UIView alloc] initWithFrame:CGRectZero];
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
        var cellData  : Server = servers[indexPath.row] as Server
        cell.serverName.text = "  http://" + cellData.address + ":" + cellData.port
        //cell.serverAddress.text = cellData.address as NSString
        return cell
    }
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        State.currentServer = indexPath.row
    }
}
