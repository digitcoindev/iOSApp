//
//  VerifyPrivateKeyBackupViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class VerifyPrivateKeyBackupViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var accountPrivateKeyTextField: UITextField!
    @IBOutlet weak var verifyBackupButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        
        informationLabel.text = "Enter the private key you have just written down to verify that it’s correct"

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
    
    @IBAction func verifyBackup(_ sender: UIButton) {
        
        let accountPrivateKey = AccountManager.sharedInstance.decryptPrivateKey(encryptedPrivateKey: account!.privateKey)
        let userEnteredPrivateKey = accountPrivateKeyTextField.text!
        
        if accountPrivateKey == userEnteredPrivateKey {
            
            let backupVerificationSuccessfulAlert = UIAlertController(title: "Verification Successful", message: "The private key you entered was correct!\nYou have successfully backed up your account", preferredStyle: .alert)
            backupVerificationSuccessfulAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned self] (action) in
                self.performSegue(withIdentifier: "unwindToWalletOverviewViewController", sender: nil)
            }))
            
            self.present(backupVerificationSuccessfulAlert, animated: true, completion: nil)
            
        } else {
            
            let backupVerificationFailureAlert = UIAlertController(title: "Verification Failed", message: "The private key you entered was incorrect!", preferredStyle: .alert)
            backupVerificationFailureAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(backupVerificationFailureAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func finishedEnteringPrivateKey(_ sender: UITextField) {
        accountPrivateKeyTextField.resignFirstResponder()
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
