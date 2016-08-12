//
//  AccountDetailTabBarController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The account detail tab bar controller that gets shown when the
    user chooses to see more details about a certain account from
    the account list view controller. This tab bar controller lets
    the user choose from different specific informations to show.
 */
class AccountDetailTabBarController: UITabBarController {
    
    // MARK: - Tab Bar Controller Properties
    
    /**
        The account object that gets provided by the account list view
        controller when the user chooses to see more details about a 
        certain account. All other view controllers inside the account
        detail tab bar controller will access this property to identify
        which information they should show.
     */
    var account: Account?
    
    // MARK: - Tab Bar Controller Lifecycle
    
    override func viewDidLoad() {
        updateTabBarControllerAppearance()
    }
    
    // MARK: - Tab Bar Conroller Helper Methods
    
    /// Updates the appearance (coloring, etc) of the tab bar controller.
    private func updateTabBarControllerAppearance() {
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(white: 0.64, alpha: 1.0)], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 65.0/255.0, green: 206.0/255.0, blue: 123.0/255.0, alpha: 1)], forState:.Selected)
        
        for item in tabBar.items! as [UITabBarItem] {
            if let normalImage = item.image {
                item.image = normalImage.imageWithColor(UIColor(white:0.64, alpha:1.0)).imageWithRenderingMode(.AlwaysOriginal)
            }
            
            if let selectedImage = item.selectedImage {
                item.selectedImage = selectedImage.imageWithColor(UIColor(red: 65.0/255.0, green: 206.0/255.0, blue: 123.0/255.0, alpha: 1)).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
    }
}
