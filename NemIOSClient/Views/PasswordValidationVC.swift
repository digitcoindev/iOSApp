//
//  PasswordValidationVC.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 30.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class PasswordValidationVC: UIViewController
{
    @IBOutlet weak var password: UITextField!
    
    let dataMeneger: CoreDataManager  = CoreDataManager()

    override func viewDidLoad()
    {
        super.viewDidLoad()

    }

    @IBAction func passwordValidation(sender: AnyObject)
    {
        var wallets: [Wallet] = dataMeneger.getWallets()
        
        if(password.text == wallets[State.currentWallet].password)
        {
            println("Segue to : " + State.toVC)
            
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:State.toVC )

        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}
