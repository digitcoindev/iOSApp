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
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    var pages :MainContainerVC = MainContainerVC();
    var deviceData :plistFileManager = plistFileManager();

    var pagesTitles :NSMutableArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        State.currentWallet = -1 as Int
        State.previousVC = "null" as String
        
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
            //(segue.destinationViewController as MainContainerVC).p = self as MainVC
        }
    }
    @IBAction func newF(sender: AnyObject)
    {
        pages.changePage(-1)
    }
    
    func pageSelected(notification: NSNotification)
    {
        print("Selected page : ")
        if(notification.object  != nil)
        {
            print("\(notification.object) \n")
        }
        pages.changePage(notification.object as Int)
    }
}
