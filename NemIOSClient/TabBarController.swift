//
//  TabBarController.swift
//  NemIOSClient
//
//  Created by Thomas Oehri on 20.07.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let _dataManager :CoreDataManager = CoreDataManager()

    override func viewDidLoad() {
        
        let wallets :[Wallet] = _dataManager.getWallets()
        let loadData = _dataManager.getLoadData()
        
//        if loadData.password == nil || loadData.salt == nil {
//            self.performSegueWithIdentifier(SegueToCreatePassword, sender: self)
//            return
//        }
        
//        if(wallets.count == 0) {
//            State.nextVC = SegueToAddAccountVC
//            self.performSegueWithIdentifier(SegueToAddAccountVC, sender: self)
//        }
//        else  {
//            
//            if State.currentWallet != nil && State.currentServer != nil{
//                State.toVC = SegueToMessages
//                State.nextVC = SegueToDashboard
//                
//            } else {
//                State.nextVC = SegueToLoginVC
//            }
//        }
//        
//        self.performSegueWithIdentifier(SegueToPasswordValidation, sender: self)
    }
}
