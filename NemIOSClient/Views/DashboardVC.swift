//
//  DashboardVC.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 30.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class DashboardVC: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createQR(sender: AnyObject)
    {
        State.toVC = SegueToQRCode
        
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToPasswordValidation )

    }
    
    @IBAction func sandMessage(sender: AnyObject)
    {
        State.toVC = SegueToMessageVC

        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToPasswordValidation )

    }
    
}
