//
//  CreateQRCodeBackupViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class CreateQRCodeBackupViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    private var backupJSONString: String?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var applicationPasswordInformationLabel: UILabel!
    @IBOutlet weak var useApplicationPasswordButton: UIButton!
    @IBOutlet weak var customPasswordInformationLabel: UILabel!
    @IBOutlet weak var customPasswordTextField: UITextField!
    @IBOutlet weak var useCustomPasswordButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        
        informationLabel.text = "Create a backup of your account by generating a QR code that holds the private key encrypted with a password of your choice - you can later import the account again by scanning the QR code and providing the password you have chosen\nChoose your password below"
        applicationPasswordInformationLabel.text = "Use your current application password as the password for the backup"
        customPasswordInformationLabel.text = "Or enter a new password which you later have to enter when importing the QR code backup again"

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showQRCodeBackupViewController":
            
            let destinationViewController = segue.destination as! QRCodeBackupViewController
            destinationViewController.account = account
            destinationViewController.backupJSONString = backupJSONString
            
        default:
            break
        }
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func useApplicationPassword(_ sender: UIButton) {
        prepareBackupData(withBackupPassword: nil)
    }
    
    @IBAction func useCustomPassword(_ sender: UIButton) {
        
        let customPassword = customPasswordTextField.text!
        prepareBackupData(withBackupPassword: customPassword)
    }
    
    @IBAction func finishedEnteringCustomPassword(_ sender: UITextField) {
        customPasswordTextField.resignFirstResponder()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Validates the input password and prepares for the account export.
    fileprivate func prepareBackupData(withBackupPassword password: String?) {
        
        let accountTitle = account!.title
        let salt = SettingsManager.sharedInstance.authenticationSalt()
        var encryptedPrivateKey = account!.privateKey
        
        if password != nil {
            
            if password!.count < 6 {
                showAlert(withMessage: "PASSOWORD_LENGTH_ERROR".localized())
                return
            }
            
            let privateKey = AccountManager.sharedInstance.decryptPrivateKey(encryptedPrivateKey: encryptedPrivateKey)
            let saltData = NSData(bytes: salt!.asByteArray(), length: salt!.asByteArray().count)
            let passwordHash = try! HashManager.generateAesKeyForString(password!, salt: saltData, roundCount: 2000)
            encryptedPrivateKey = HashManager.AES256Encrypt(inputText: privateKey, key: passwordHash!.hexadecimalString())
        }
        
        let jsonData = JSON([QRKeys.dataType.rawValue: QRType.accountData.rawValue, QRKeys.version.rawValue: Constants.qrVersion, QRKeys.data.rawValue: [ QRKeys.name.rawValue: accountTitle, QRKeys.salt.rawValue: salt!, QRKeys.privateKey.rawValue: encryptedPrivateKey ]])
        let jsonString = jsonData.rawString()
        backupJSONString = jsonString
        
        performSegue(withIdentifier: "showQRCodeBackupViewController", sender: nil)
    }
    
    /**
        Shows an alert view controller with the provided alert message.
     
        - Parameter message: The message that should get shown.
        - Parameter completion: An optional action that should get performed on completion.
     */
    fileprivate func showAlert(withMessage message: String, completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        useApplicationPasswordButton.layer.cornerRadius = 10.0
        useCustomPasswordButton.layer.cornerRadius = 10.0
    }
}
