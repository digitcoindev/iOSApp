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
    
    var pages :MainContainerVC = MainContainerVC();
    var dataManager :plistFileManager = plistFileManager();

    var pagesTitles :NSMutableArray = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        pagesTitles  = dataManager.getMenuItems()
        
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
    func echoF()
    {
        println("echo")
    }
}
