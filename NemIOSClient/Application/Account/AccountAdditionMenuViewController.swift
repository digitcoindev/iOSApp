//
//  AccountAdditionMenuViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The account addition menu view controller that gets shown when
    the user taps on the account addition button inside the account
    list view controller in order to add a new account. This menu 
    view controller gives the user the ability to choose if he wants
    to create a new account, add an existing account via QR code or
    add an existing account via public key.
 */
class AccountAdditionMenuViewController: UIViewController {
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var createNewAccountButton: UIButton!
    @IBOutlet weak var addExistingAccountViaQRCodeButton: UIButton!
    @IBOutlet weak var addExistingAccountViaPrivateKeyButton: UIButton!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad(){
        super.viewDidLoad()
        
        updateViewControllerAppearance()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        title = "ADD_ACCOUNT".localized()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        createNewAccountButton.setTitle("CREATE_NEW".localized(), forState: .Normal)
        addExistingAccountViaQRCodeButton.setTitle("SCAN_QR_CODE".localized(), forState: .Normal)
        addExistingAccountViaPrivateKeyButton.setTitle("IMPORT_KEY".localized(), forState: .Normal)
        
        createNewAccountButton.layer.cornerRadius = 5
        addExistingAccountViaQRCodeButton.layer.cornerRadius = 5
        addExistingAccountViaPrivateKeyButton.layer.cornerRadius = 5
    }
    
    // MARK: - View Controller Outlet Actions
    
    /**
        Dismisses the account addition menu view controller and returns
        to the account list view controller.
     */
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
