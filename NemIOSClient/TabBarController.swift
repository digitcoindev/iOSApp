//
//  TabBarController.swift
//  NemIOSClient
//
//  Created by Thomas Oehri on 20.07.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
//    private let _dataManager :CoreDataManager = CoreDataManager()

    override func viewDidLoad() {
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(white: 0.64, alpha: 1.0)], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 65.0/255.0, green: 206.0/255.0, blue: 123.0/255.0, alpha: 1)], forState:.Selected)
        
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor(white:0.64, alpha:1.0)).imageWithRenderingMode(.AlwaysOriginal)
            } else {

            }
            
            if let selectedImage = item.selectedImage {
                item.selectedImage = selectedImage.imageWithColor(UIColor(red: 65.0/255.0, green: 206.0/255.0, blue: 123.0/255.0, alpha: 1)).imageWithRenderingMode(.AlwaysOriginal)
            } else {
            }
        }
        
//        let wallets :[Wallet] = _dataManager.getWallets()
//        let loadData = _dataManager.getLoadData()
        
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
