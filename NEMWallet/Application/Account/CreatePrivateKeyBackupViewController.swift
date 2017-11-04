//
//  CreatePrivateKeyBackupViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class CreatePrivateKeyBackupViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var accountPrivateKeyLabel: UILabel!
    @IBOutlet weak var verifyBackupButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateAppearance()
        
        informationLabel.text = "Write down the accounts private key and store it in a safe place - you’re then able to import that account into any NEM client again, but remember that anyone who has access to your private key has also access to your account and therefore to your funds!"
        accountPrivateKeyLabel.text = account?.privateKey != nil ? AccountManager.sharedInstance.decryptPrivateKey(encryptedPrivateKey: account!.privateKey) : "-"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showVerifyPrivateKeyBackupViewController":
            
            let destinationViewController = segue.destination as! VerifyPrivateKeyBackupViewController
            destinationViewController.account = account
            
        default:
            break
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        verifyBackupButton.layer.cornerRadius = 10.0
    }
}
