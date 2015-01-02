//
//  LoginVC.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 17.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class LoginVC: UIViewController , UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWallet: UIButton!
    
    let deviceManager :plistFileManager = plistFileManager()
    let dataManager :CoreDataManager = CoreDataManager()
    let apiManager :APIManager = APIManager()
    
    var wallets :[Wallet] = [Wallet]()
    var selectedIndex :Int  = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        wallets  = dataManager.getWallets()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addNewWallet(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToRegistrationVC )
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return wallets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : WalletCell = self.tableView.dequeueReusableCellWithIdentifier("walletCell") as WalletCell
        var cellData  :Wallet = wallets[indexPath.row]
        cell.walletName.text = cellData.login as String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        State.currentWallet = indexPath.row
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToDashboard )
    }
    
 //   @IBAction func logIn(sender: AnyObject)
  //  {
//        if((wallets[accountsView.selectedRowInComponent(0)] as Wallet).valueForKey("password") as String == password.text as String)
//        {
//            var alert :UIAlertView = UIAlertView(title: "Status", message: "Login - Success", delegate: self, cancelButtonTitle: "OK")
// //           var server : NSMutableDictionary = deviceManager.currentServer()
//            
////            if(!apiManager.heartbeat(server.objectForKey("address") as String, port: server.objectForKey("port") as String))
////            {
////                alert.message = ((alert.message as String) + "\n" + "heartbeat - Success") as String
////                
//////                if ((deviceManager.currentServer().objectForKey("address") as String) != "" && (deviceManager.currentServer().objectForKey("name") as String ) != "" )
//////                {
//////                    self.performSegueWithIdentifier(SegueToMainVC, sender: nil)
//////                }
//////                else
//////                {
//////                    self.performSegueWithIdentifier(SegueToServerVC, sender: nil)
//////                }
////                
////            }
////            else
////            {
////                alert.message = (alert.message! + "\n" + "heartbeat - Defied") as String
////            }
////            alert.show()
//            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:nil )
//            
//        }
//        else
//        {
//            var alert :UIAlertView = UIAlertView(title: "Status", message: "Wrong login & password pair", delegate: self, cancelButtonTitle: "OK")
//            alert.show()
//        }
//    }
  //  }
}
