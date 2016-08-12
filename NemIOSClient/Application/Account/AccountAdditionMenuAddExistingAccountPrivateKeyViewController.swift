//
//  AccountAdditionMenuAddExistingAccountPrivateKeyViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The view controller that lets the user add an existing account by
    importing a private key.
 */
class AccountAdditionMenuAddExistingAccountPrivateKeyViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    private var accountTitle = String()
    private var accountPrivateKey = String()
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var accountPrivateKeyTextField: UITextField!
    @IBOutlet weak var accountTitleTextField: UITextField!
    @IBOutlet weak var addAccountButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewControllerAppearance()
        addKeyboardObserver()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        title = "IMPORT_FROM_KEY".localized()
        accountPrivateKeyTextField.placeholder = "PRIVATE_KEY".localized()
        accountTitleTextField.placeholder = "NAME".localized()
        addAccountButton.setTitle("ADD_ACCOUNT".localized(), forState: UIControlState.Normal)
        
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    /// Adds all needed keyboard observers to the view controller.
    private func addKeyboardObserver() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountAdditionMenuAddExistingAccountPrivateKeyViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountAdditionMenuAddExistingAccountPrivateKeyViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /// Makes the scroll view scrollable as soon as the keyboard shows.
    func keyboardWillShow(notification: NSNotification) {
        
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        var keyboardHeight:CGFloat = keyboardSize.height
        keyboardHeight -= self.view.frame.height - self.scrollView.frame.height
        
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight - 10, 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 15, 0)
    }
    
    /// Resets the scroll view as soon as the keyboard hides.
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    /**
        Validates entered information.
     
        - Throws:
            - AccountImportValidation.ValueMissing if a value wasn't provided.
            - AccountImportValidation.InvalidPrivateKey if the provided private key isn't valid.
            - AccountImportValidation.AccountAlreadyPresent if an account with the provided private key was already added to the application.
     
        - Returns: A bool indicating that the validation was successful.
     */
    private func validateEntries() throws -> Bool {
        
        guard let accountTitle = accountTitleTextField.text else { throw AccountImportValidation.ValueMissing }
        guard let accountPrivateKey = accountPrivateKeyTextField.text else { throw AccountImportValidation.ValueMissing }
        guard accountTitle != String() else { throw AccountImportValidation.ValueMissing }
        guard accountPrivateKey != String() else { throw AccountImportValidation.ValueMissing }
        guard let accountPrivateKeyNormalized = accountPrivateKey.nemKeyNormalized() else { throw AccountImportValidation.InvalidPrivateKey }
        
        do {
            try AccountManager.sharedInstance.validateAccountExistence(forAccountWithPrivateKey: accountPrivateKeyNormalized)
            
            self.accountTitle = accountTitle
            self.accountPrivateKey = accountPrivateKeyNormalized
            
        } catch AccountImportValidation.AccountAlreadyPresent(let existingAccountTitle) {
            throw AccountImportValidation.AccountAlreadyPresent(accountTitle: existingAccountTitle)
        }
        
        return true
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func importAccount(sender: UIButton) {
        
        do {
            try validateEntries()
            
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
            
        } catch AccountImportValidation.ValueMissing {
            
            let importAccountValueMissingAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: "FIELDS_EMPTY_ERROR".localized(), preferredStyle: UIAlertControllerStyle.Alert)
            
            importAccountValueMissingAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(importAccountValueMissingAlert, animated: true, completion: nil)
            
        } catch AccountImportValidation.InvalidPrivateKey {
            
            let importAccountInvalidPrivateKeyAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: "PRIVATE_KEY_ERROR_1".localized(), preferredStyle: UIAlertControllerStyle.Alert)
            
            importAccountInvalidPrivateKeyAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(importAccountInvalidPrivateKeyAlert, animated: true, completion: nil)
            
        } catch AccountImportValidation.AccountAlreadyPresent(let existingAccountTitle) {
            
            let importAccountAlreadyPresentAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: String(format: "VIDATION_ACCOUNT_EXIST".localized(), arguments:[existingAccountTitle]), preferredStyle: UIAlertControllerStyle.Alert)
            
            importAccountAlreadyPresentAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(importAccountAlreadyPresentAlert, animated: true, completion: nil)
            
        } catch {
            
            let importAccountOtherAlert: UIAlertController = UIAlertController(title: "VALIDATION".localized(), message: "Couldn't add account", preferredStyle: UIAlertControllerStyle.Alert)
            
            importAccountOtherAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(importAccountOtherAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func textFieldFocused(sender: UITextField) {
        validateTextField(sender)
        scrollView.scrollRectToVisible(sender.convertRect(sender.frame, toView: self.view), animated: true)
    }
    
    @IBAction func validateTextField(sender: UITextField){
        
        switch sender {
        case accountPrivateKeyTextField:
            
            if AccountManager.sharedInstance.validateKey(accountPrivateKeyTextField.text!) {
                sender.textColor = UIColor.greenColor()
            } else {
                sender.textColor = UIColor.redColor()
            }
            
        default:
            return
        }
    }
    
    @IBAction func changeTextField(sender: UITextField) {
        
        switch sender {
        case accountPrivateKeyTextField:
            
            accountTitleTextField.becomeFirstResponder()
            textFieldFocused(accountTitleTextField)
            
        case accountTitleTextField:
            
            if accountPrivateKeyTextField.text == "" {
                accountPrivateKeyTextField.becomeFirstResponder()
                textFieldFocused(accountPrivateKeyTextField)
            }
            
        default :
            break
        }
    }
}
