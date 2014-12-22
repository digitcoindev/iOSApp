//
//  ViewController.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 11.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

var SegueToServerVC : String =  "toServerVC"
var SegueToRegistrationrVC : String =  "toRegistrationVC"
var SegueToLoginVC : String =  "toLoginVC"
var SegueToServerTable : String =  "serverTable"
var SegueToServerCustom : String =  "serverCustom"
var SegueToMainVC : String =  "toMainVC"
var SegueToMainMenu : String =  "toMenu"

class ViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func registrationTouchIn(sender: AnyObject)
    {
        self.performSegueWithIdentifier(SegueToRegistrationrVC, sender: nil)
    }

    @IBAction func loginTouchIn(sender: AnyObject)
    {
        self.performSegueWithIdentifier(SegueToLoginVC, sender: nil)
    }
}

