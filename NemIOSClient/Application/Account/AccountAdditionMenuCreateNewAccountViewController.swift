//
//  AccountAdditionMenuCreateNewAccountViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The account addition menu create new account view controller that lets
    the user create/generate a completely new account.
 */
class AccountAdditionMenuCreateNewAccountViewController: UIViewController {
    
    // MARK: - View Controller Properties

    @IBOutlet weak var accountTitleTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
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
        
        title = "CREATE_NEW_ACCCOUNT".localized()
        createAccountButton.setTitle("CREATE_NEW_ACCCOUNT".localized(), forState: UIControlState.Normal)
        accountTitleTextField.placeholder = "ACCOUNT_NAME_PLACEHOLDER".localized()
        
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    /// Adds all needed keyboard observers to the view controller.
    private func addKeyboardObserver() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountAdditionMenuCreateNewAccountViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountAdditionMenuCreateNewAccountViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
        Validates entered information by the user and creates a new
        account accordingly and stores that new account in the database.
        Unwinds to the account list view controller if the account got
        created successfully.
     
        - Parameter title: The title for the new account.
     */
    private func createAccount(withTitle title: String) {
        
        do {
            try validate(enteredInformation: title)
            
            AccountManager.sharedInstance.create(account: title, completion: { (result) in
                switch result {
                case .Success:
                    self.performSegueWithIdentifier("unwindToAccountListViewController", sender: nil)
                    
                case .Failure:
                    let accountCreationFailureAlert = UIAlertController(title: "Error", message: "Couldn't create account", preferredStyle: .Alert)
                    
                    accountCreationFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: nil))
                    
                    self.presentViewController(accountCreationFailureAlert, animated: true, completion: nil)
                }
            })
            
        } catch AccountTitleValidation.Empty {
            
            let accountTitleEmptyAlert = UIAlertController(title: "VALIDATION".localized(), message: "FIELDS_EMPTY_ERROR".localized(), preferredStyle: .Alert)
            
            accountTitleEmptyAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: nil))
            
            presentViewController(accountTitleEmptyAlert, animated: true, completion: nil)
            
        } catch {
            return
        }
    }
    
    /**
        Validates the entered information by the user.
     
        - Parameter title: The title for the new account entered by the user.
     
        - Throws: 
            - AccountTitleValidation.Empty if the title parameter string is empty.
     
        - Returns: A bool indicating that the validation was successful.
     */
    private func validate(enteredInformation title: String) throws -> Bool {
    
        guard title != String() else { throw AccountTitleValidation.Empty }
        
        return true
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
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func accountTitleTextFieldFocused(sender: UITextField) {
        scrollView.scrollRectToVisible(view.convertRect(sender.frame, fromView: sender), animated: true)
    }
        
    @IBAction func createAccountButtonPressed(sender: AnyObject) {
        
        if let accountTitle = accountTitleTextField.text {
            createAccount(withTitle: accountTitle)
        }
    }
    
    @IBAction func changeField(sender: UITextField) {
        sender.endEditing(true)
    }
}
