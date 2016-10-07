//
//  AuthenticationPasswordValidationViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import LocalAuthentication

/// The view controller that lets the user authenticate.
class AuthenticationPasswordValidationViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    fileprivate var shouldAskForTouchID = false
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var passwordHeadingLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmationButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewControllerAppearance()
        
        passwordTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        shouldAskForTouchID = true
        applicationDidBecomeActive(nil)
    }
    
    override func  viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationDidBecomeActive(_ notification: Notification?) {
        
        if SettingsManager.sharedInstance.authenticationTouchIDStatus() == true && shouldAskForTouchID {
            shouldAskForTouchID = false
            handleTouchIDAuthentication()
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        passwordHeadingLabel.text = "ENTET_PASSWORD".localized()
        passwordTextField.placeholder = "PASSWORD_PLACEHOLDER".localized()
        confirmationButton.setTitle("CONFIRM".localized(), for: UIControlState())
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    /// Handles authentication via password.
    fileprivate func handlePasswordAuthentication() {
        
        guard passwordTextField.text != nil else { return }
        let salt = SettingsManager.sharedInstance.authenticationSalt()
        let saltData = NSData.fromHexString(salt!)
        let encryptedPassword = SettingsManager.sharedInstance.applicationPassword()
        
        let passwordData: NSData? = try! HashManager.generateAesKeyForString(passwordTextField.text!, salt: saltData, roundCount: 2000)!
        
        if passwordData?.toHexString() == encryptedPassword {
            
            authenticationSuccessful()
            
        } else {
            
            passwordTextField.textColor = UIColor.red
        }
    }
    
    /// Handles the whole touch id authentication process.
    fileprivate func handleTouchIDAuthentication() {
        
        let localAuthenticationContext = LAContext()
        var error: NSError?
        
        if (localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("Authorize by fingerprint", comment: "")) {
                [weak self] (success: Bool, _) -> Void in
                
                DispatchQueue.main.async {
                    
                    if success {
                        
                        self?.authenticationSuccessful()
                        
                    } else {
                        
                        if let error = error {
                            if error.code == LAError.touchIDNotEnrolled.rawValue {
                                
                                let alertController = UIAlertController(title: "Touch ID isn't configured", message: "You first have to configure Touch ID in the device settings", preferredStyle: .alert)
                                
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                self?.present(alertController, animated: true, completion: nil)
                                
                            } else {
                                
                                print("user provided touch id wasn't correct: \(error), \(error.userInfo), \(error.code)")
                            }
                            
                        } else {
                            
                            print("no authentication error code provided by local authentication despite failure")
                        }
                    }
                }
            }
            
        } else {
            
            print("touch id isn't available: \(error), \(error!.userInfo)")
        }
    }
    
    /// Makes the transition to the application after successful authentication.
    fileprivate func authenticationSuccessful() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let rootViewController = appDelegate.window?.rootViewController {
            if (rootViewController == self) {
                
                self.performSegue(withIdentifier: "showRootNavigationController", sender: nil)
                
            } else {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - View Controller Outlet Actions

    @IBAction func editingDidBegin(_ sender: UITextField) {
        
        passwordTextField.textColor = UIColor.black
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        
        passwordTextField.endEditing(true)
        handlePasswordAuthentication()
    }
}
