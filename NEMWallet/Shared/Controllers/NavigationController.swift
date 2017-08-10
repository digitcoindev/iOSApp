//
//  NavigationController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/// A navigation controller with the NEM specific appearance.
final class NavigationController: UINavigationController {

    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAppearance()
    }
    
    // MARK: - Controller Helper Methods
    
    /// Updates the appearance of the controller.
    fileprivate func updateAppearance() {
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = Constants.nemBlue
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
    }
}
