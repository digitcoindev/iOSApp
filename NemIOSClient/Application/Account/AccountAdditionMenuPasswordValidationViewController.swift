//
//  AccountAdditionMenuPasswordValidationViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    Lets the user verify his password in order to import an
    existing account via QR code. Imports the account and unwinds
    to the account list once the user provided password was verified
    successfully.
 */
class AccountAdditionMenuPasswordValidationViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    var accountTitle = String()
    var accountEncryptedPrivateKey = String()
    var accountSalt = String()
    private var accountPrivateKey = String()
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewControllerAppearance()
        
        self.navigationBar.delegate = self
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        customNavigationItem.title = "ENTET_PASSWORD".localized()
        passwordTextField.placeholder = "   " + "PASSWORD_PLACEHOLDER".localized()
        confirmationButton.setTitle("CONFIRM".localized(), forState: UIControlState.Normal)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    /**
        Verifies that the entered password is valid and therefore
        able to decrypt the imported and encrypted private key.
     
        - Throws: 
            - AccountImportValidation.NoPasswordProvided if no password was provided.
            - AccountImportValidation.WrongPasswordProvided if the provided password is invalid.
            - AccountImportValidation.AccountAlreadyPresent if an account with the same private key already is present in the application.
            - AccountImportValidation.Other if generating a hash failed.

        - Returns: A bool indicating that the verification was successful.
     */
    private func verifyPassword() throws -> Bool {
        
        guard let enteredPassword = passwordTextField.text else { throw AccountImportValidation.NoPasswordProvided }
        
        let accountSaltBytes = accountSalt.asByteArray()
        let accountSaltData = NSData(bytes: accountSaltBytes, length: accountSaltBytes.count)

        guard let passwordHash = try? HashManager.generateAesKeyForString(enteredPassword, salt: accountSaltData, roundCount:2000) else { throw AccountImportValidation.Other }
        guard let accountPrivateKey = HashManager.AES256Decrypt(accountEncryptedPrivateKey, key: passwordHash!.toHexString())?.nemKeyNormalized() else { throw AccountImportValidation.WrongPasswordProvided }
                                
        do {
            try AccountManager.sharedInstance.validateAccountExistence(forAccountWithPrivateKey: accountPrivateKey)
            self.accountPrivateKey = accountPrivateKey
            
            return true
            
        } catch AccountImportValidation.AccountAlreadyPresent(let existingAccountTitle) {
            throw AccountImportValidation.AccountAlreadyPresent(accountTitle: existingAccountTitle)
        }
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func verifyPassword(sender: UIButton) {
        
        passwordTextField.endEditing(true)
        
        do {
            try verifyPassword()
            
            AccountManager.sharedInstance.create(account: accountTitle, withPrivateKey: accountPrivateKey, completion: { (result) in
                
                switch result {
                case .Success:
                    self.performSegueWithIdentifier("unwindToAccountListViewController", sender: nil)
                    
                case .Failure:
                    let accountCreationFailureAlert = UIAlertController(title: "Error", message: "Couldn't create account", preferredStyle: .Alert)
                    
                    accountCreationFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: nil))
                    
                    self.presentViewController(accountCreationFailureAlert, animated: true, completion: nil)
                }
            })
            
        } catch AccountImportValidation.AccountAlreadyPresent(let existingAccountTitle) {
            
            let accountAlreadyPresentAlert = UIAlertController(title: "VALIDATION".localized(), message: String(format: "VIDATION_ACCOUNT_EXIST".localized(), arguments:[existingAccountTitle]), preferredStyle: .Alert)
            
            accountAlreadyPresentAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: nil))
            
            self.presentViewController(accountAlreadyPresentAlert, animated: true, completion: nil)
            
        } catch AccountImportValidation.WrongPasswordProvided {
            
            let verificationFailureAlert = UIAlertController(title: "Error", message: "Wrong password provided", preferredStyle: .Alert)
            
            verificationFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: nil))
            
            presentViewController(verificationFailureAlert, animated: true, completion: nil)
            
        } catch {
            
            let accountCreationFailureAlert = UIAlertController(title: "Error", message: "Couldn't create account", preferredStyle: .Alert)
            
            accountCreationFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: nil))
            
            presentViewController(accountCreationFailureAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Navigation Bar Delegate

extension AccountAdditionMenuPasswordValidationViewController: UINavigationBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
