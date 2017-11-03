//
//  CreateAccountViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class CreateAccountViewController: UIViewController {
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateAppearance()
        
        informationLabel.text = "Create a completely new account\nIt is essential that you backup your new account in the next step after creation"
        
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
    
    @IBAction func createAccount(_ sender: UIButton) {
        
        if let accountTitle = accountNameTextField.text {
            createAccount(withTitle: accountTitle)
        }
    }
    
    @IBAction func finishedEnteringAccountName(_ sender: UITextField) {
        accountNameTextField.resignFirstResponder()
    }
    
    // MARK: - View Controller Helper Methods
    
    /**
        Validates entered information by the user and creates a new
        account accordingly and stores that new account in the database.
        Unwinds to the account list view controller if the account got
        created successfully.
     
        - Parameter title: The title for the new account.
     */
    fileprivate func createAccount(withTitle title: String) {
        
        do {
            let _ = try validate(enteredInformation: title)
            
            AccountManager.sharedInstance.create(account: title, completion: { [unowned self] (result, _) in
                
                switch result {
                case .success:
                    
                    let alert = UIAlertController(title: "Warning", message: "The account was successfully created. Don't forget to backup your private key! Select your account on the dashboard, go to 'more' -> 'export account'", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { [unowned self] (action) -> Void in
                        self.performSegue(withIdentifier: "unwindToWalletOverviewViewController", sender: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                case .failure:
                    
                    let accountCreationFailureAlert = UIAlertController(title: "Error", message: "Couldn't create account", preferredStyle: .alert)
                    
                    accountCreationFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
                    
                    self.present(accountCreationFailureAlert, animated: true, completion: nil)
                }
            })
            
        } catch AccountImportValidation.valueMissing {
            
            let accountTitleEmptyAlert = UIAlertController(title: "VALIDATION".localized(), message: "FIELDS_EMPTY_ERROR".localized(), preferredStyle: .alert)
            
            accountTitleEmptyAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
            
            present(accountTitleEmptyAlert, animated: true, completion: nil)
            
        } catch {
            return
        }
    }
    
    /**
        Validates the entered information by the user.
     
        - Parameter title: The title for the new account entered by the user.
     
        - Throws:
        - AccountImportValidation.ValueMissing if the title parameter string is empty.
     
        - Returns: A bool indicating that the validation was successful.
     */
    fileprivate func validate(enteredInformation title: String) throws -> Bool {
        
        guard title != String() else { throw AccountImportValidation.valueMissing }
        
        return true
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        createAccountButton.layer.cornerRadius = 10.0
    }
}
