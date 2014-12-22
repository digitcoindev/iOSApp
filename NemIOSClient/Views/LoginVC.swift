//
//  LoginVC.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 17.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class LoginVC: UIViewController , UIPickerViewDelegate
{

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var accountsView: UIPickerView!
    
    let dataManager :plistFileManager = plistFileManager()
    var wallets :NSMutableArray = NSMutableArray()
    var apiManager :APIManager = APIManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        accounts  = dataManager.getAccounts()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return wallets.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return (wallets[row] as NSDictionary).objectForKey("login") as String
    }
    
    @IBAction func logIn(sender: AnyObject)
    {
        if((wallets[accountsView.selectedRowInComponent(0)] as NSDictionary).valueForKey("password") as String == password.text as String)
        {
            var alert :UIAlertView = UIAlertView(title: "Status", message: "Login - Success", delegate: self, cancelButtonTitle: "OK")
            var server : NSMutableDictionary = dataManager.currentServer()
            
            if(!apiManager.heartbeat(server.objectForKey("address") as String, port: server.objectForKey("port") as String))
            {
                alert.message = (alert.message! + "\n" + "heartbeat - Success") as String
                
                if ((dataManager.currentServer().objectForKey("address") as String) != "" && (dataManager.currentServer().objectForKey("name") as String ) != "" )
                {
                    self.performSegueWithIdentifier(SegueToMainVC, sender: nil)
                }
                else
                {
                    self.performSegueWithIdentifier(SegueToServerVC, sender: nil)
                }
                
            }
            else
            {
                alert.message = (alert.message! + "\n" + "heartbeat - Defied") as String
            }
            alert.show()
            
        }
        else
        {
            var alert :UIAlertView = UIAlertView(title: "Status", message: "Wrong login & password pair", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }

}
