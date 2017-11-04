//
//  CreateBackupViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class CreateBackupViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var allowCancelling = false
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var privateKeyBackupInformationLabel: UILabel!
    @IBOutlet weak var showPrivateKeyButton: UIButton!
    @IBOutlet weak var qrCodeBackupInformationLabel: UILabel!
    @IBOutlet weak var generateQRCodeBackupButton: UIButton!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateAppearance()
        createCancelButtonIfNecessary()
        
        informationLabel.text = "Your new account was successfully created!\nNow create a backup of the newly generated account by one of the following methods"
        privateKeyBackupInformationLabel.text = "Create a backup of your account by writing down the accounts private key and storing it in a safe place - you are then able to import the account with the private key into any NEM client, but remember that anyone who has access to your private key has also access to your account and therefore to your funds!"
        qrCodeBackupInformationLabel.text = "Create a backup of your account by generating a QR code that holds the private key encrypted with a password of your choice - you can later import the account again by scanning the QR code and providing the password you have chosen"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showCreatePrivateKeyBackupViewController":
            
            let destinationViewController = segue.destination as! CreatePrivateKeyBackupViewController
            destinationViewController.account = account
            
        case "showCreateQRCodeBackupViewController":
            
            let destinationViewController = segue.destination as! CreateQRCodeBackupViewController
            destinationViewController.account = account
            
        default:
            break
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    ///
    private func createCancelButtonIfNecessary() {
        
        if allowCancelling {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    ///
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        showPrivateKeyButton.layer.cornerRadius = 10.0
        generateQRCodeBackupButton.layer.cornerRadius = 10.0
    }
}
