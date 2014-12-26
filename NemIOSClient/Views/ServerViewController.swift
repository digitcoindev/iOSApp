//
//  ServerViewController.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 11.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit
class ServerViewController: UIViewController
{
    @IBOutlet weak var pageNumber: UISegmentedControl!
    
    var pages :ServerContainerVC = ServerContainerVC();
    
    let dataManager : CoreDataManager = CoreDataManager()
    var servers : NSArray = NSArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        servers = dataManager.getServers()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "serverContainer")
        {
            pages = segue.destinationViewController as ServerContainerVC
        }
    }

    @IBAction func chousePage(sender: AnyObject)
    {
        pages.changePage(pageNumber.selectedSegmentIndex)
    }

}
