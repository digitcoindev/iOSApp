//
//  ImportAccountByPKViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class ImportAccountByPKViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    fileprivate var accountTitle = String()
    fileprivate var accountPrivateKey = String()
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var accountPrivateKeyTextField: UITextField!
    @IBOutlet weak var importAccountButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateAppearance()
        
        informationLabel.text = "Import an existing account by entering the accounts private key"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func importAccount(_ sender: UIButton) {
        
        do {
            let _ = try validateEntries()
            
            AccountManager.sharedInstance.create(account: accountTitle, withPrivateKey: accountPrivateKey, completion: { [unowned self] (result, _) in
                
                switch result {
                case .success:
                    
                    let accountCreationSuccessfulAlert = UIAlertController(title: "Success", message: "The account was successfully imported!", preferredStyle: .alert)
                    
                    accountCreationSuccessfulAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "unwindToWalletOverviewViewController", sender: nil)
                    }))
                    
                    self.present(accountCreationSuccessfulAlert, animated: true, completion: nil)
                    
                case .failure:
                    let accountCreationFailureAlert = UIAlertController(title: "Error", message: "Couldn't create account", preferredStyle: .alert)
                    
                    accountCreationFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
                    
                    self.present(accountCreationFailureAlert, animated: true, completion: nil)
                }
            })
            
        } catch AccountImportValidation.valueMissing {
            
            let importAccountValueMissingAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: "FIELDS_EMPTY_ERROR".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            importAccountValueMissingAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            present(importAccountValueMissingAlert, animated: true, completion: nil)
            
        } catch AccountImportValidation.invalidPrivateKey {
            
            let importAccountInvalidPrivateKeyAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: "PRIVATE_KEY_ERROR_1".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            importAccountInvalidPrivateKeyAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            present(importAccountInvalidPrivateKeyAlert, animated: true, completion: nil)
            
        } catch AccountImportValidation.accountAlreadyPresent(let existingAccountTitle) {
            
            let importAccountAlreadyPresentAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: String(format: "VIDATION_ACCOUNT_EXIST".localized(), arguments:[existingAccountTitle]), preferredStyle: UIAlertControllerStyle.alert)
            
            importAccountAlreadyPresentAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            present(importAccountAlreadyPresentAlert, animated: true, completion: nil)
            
        } catch {
            
            let importAccountOtherAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: "Couldn't add account", preferredStyle: UIAlertControllerStyle.alert)
            
            importAccountOtherAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            present(importAccountOtherAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func finishedEnteringAccountDetails(_ sender: UITextField) {
        
        switch sender {
        case accountNameTextField:
            accountPrivateKeyTextField.becomeFirstResponder()
        case accountPrivateKeyTextField:
            accountPrivateKeyTextField.resignFirstResponder()
        default:
            break
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /**
        Validates entered information.
     
        - Throws:
        - AccountImportValidation.ValueMissing if a value wasn't provided.
        - AccountImportValidation.InvalidPrivateKey if the provided private key isn't valid.
        - AccountImportValidation.AccountAlreadyPresent if an account with the provided private key was already added to the application.
     
        - Returns: A bool indicating that the validation was successful.
     */
    fileprivate func validateEntries() throws -> Bool {
        
        guard let accountTitle = accountNameTextField.text else { throw AccountImportValidation.valueMissing }
        guard let accountPrivateKey = accountPrivateKeyTextField.text else { throw AccountImportValidation.valueMissing }
        guard accountTitle != String() else { throw AccountImportValidation.valueMissing }
        guard accountPrivateKey != String() else { throw AccountImportValidation.valueMissing }
        guard let accountPrivateKeyNormalized = accountPrivateKey.nemKeyNormalized() else { throw AccountImportValidation.invalidPrivateKey }
        
        do {
            let _ = try AccountManager.sharedInstance.validateAccountExistence(forAccountWithPrivateKey: accountPrivateKeyNormalized)
            
            self.accountTitle = accountTitle
            self.accountPrivateKey = accountPrivateKeyNormalized
            
        } catch AccountImportValidation.accountAlreadyPresent(let existingAccountTitle) {
            throw AccountImportValidation.accountAlreadyPresent(accountTitle: existingAccountTitle)
        }
        
        return true
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        importAccountButton.layer.cornerRadius = 10.0
    }
}
