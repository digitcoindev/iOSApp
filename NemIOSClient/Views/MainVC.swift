//
//  MainVC.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 19.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class MainVC: UIViewController
{
    
    @IBOutlet weak var status: UILabel!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    var pages :MainContainerVC = MainContainerVC()
    var deviceData :plistFileManager = plistFileManager()

    var pagesTitles :NSMutableArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        State.currentWallet = -1 as Int
        State.fromVC = "null" as String
        
        observer.addObserver(self, selector: "pageSelected:", name: "MenuPage", object: nil)

        pagesTitles  = deviceData.getMenuItems()
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if(segue.identifier == "mainContainer")
        {
            pages = segue.destinationViewController as MainContainerVC
        }
    }
    @IBAction func newF(sender: AnyObject)
    {
        status.text = SegueToMainMenu as String
        pages.changePage(SegueToMainMenu)
    }
    
    func pageSelected(notification: NSNotification)
    {
        print("Selected page : ")
        if(notification.object  != nil)
        {
            status.text = notification.object as? String
            print("\(notification.object) \n")
        }
        pages.changePage(notification.object as String)
    }
}
