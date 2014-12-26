//
//  PinVC.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 22.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class PinVC: UIViewController
{
    @IBOutlet weak var inputPin: UITextField!
    
    let deviceData : plistFileManager = plistFileManager()
    let dataManager :CoreDataManager = CoreDataManager()
    
    var pin : String = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var users :[User] = dataManager.getUsers() as [User]
        
        println("Users : \(users.count)")
        pin = dataManager.userPin()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pinEntered(sender: AnyObject)
    {
        if(pin == inputPin.text)
        {
            dataManager.userPinState("1")
            self.dismissViewControllerAnimated(true , completion:
                {
                  () -> Void in
            })
            println("Users : \(dataManager.userPin())")
        }
    }
    
}
