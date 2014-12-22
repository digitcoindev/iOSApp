//
//  RegistrationVC.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 17.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit
class RegistrationVC: UIViewController
{
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    let manager : plistFileManager = plistFileManager()
    var passwordValidate :Bool = false
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func validatePassword(sender: AnyObject)
    {
        if(countElements(createPassword.text)  < 6 )
        {
            var alert :UIAlertView = UIAlertView(title: "Validation", message: "To short password", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            createPassword.text = ""
        }
    }
    
    @IBAction func confirmPassword(sender: AnyObject)
    {

    }
    
    @IBAction func nextBtnPressed(sender: AnyObject)
    {
        if(createPassword.text == repeatPassword.text)
        {
            passwordValidate = true;
        }
        else if(!passwordValidate)
        {
            var alert :UIAlertView = UIAlertView(title: "Validation", message: "Different passwords", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            repeatPassword.text = ""
        }
        
        if(passwordValidate && userName.text != "" && userEmail.text != "")
        {
            manager.addAcounnt(userName.text, email: userEmail.text, password:createPassword.text)
            self.performSegueWithIdentifier(SegueToLoginVC, sender: nil)
        }
        else
        {
            var alert :UIAlertView = UIAlertView(title: "Validation", message: "Input all fields", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
        }
    }
}
