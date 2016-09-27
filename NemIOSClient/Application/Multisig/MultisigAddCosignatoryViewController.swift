//
//  MultisigAddCosignatoryViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/// The view controller that lets the user add a new multisig cosigner.
class MultisigAddCosignatoryViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    var newCosignatoryPublicKey: String?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var cosignatoryIdentifierTextField: NEMTextField!
    @IBOutlet weak var addCosignatoryButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.delegate = self
        
        updateViewControllerAppearance()
        
//        _setSuggestions()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewTopConstraint.constant = self.navigationBar.frame.height
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        customNavigationItem.title = "ADD_COSIGNATORY".localized()
        cosignatoryIdentifierTextField.placeholder = "   " + "INPUT_PUBLIC_KEY".localized()
        addCosignatoryButton.setTitle("ADD_COSIGNATORY".localized(), for: UIControlState())
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    /**
        Shows an alert view controller with the provided alert message.
     
        - Parameter message: The message that should get shown.
        - Parameter completion: An optional action that should get performed on completion.
     */
    fileprivate func showAlert(withMessage message: String, completion: ((Void) -> Void)? = nil) {
        
        let alert = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func _setSuggestions() {
//        let suggestions :[NEMTextField.Suggestion] = []
////        let dataManager = CoreDataManager()
//        
////        for wallet in dataManager.getWallets() {
////            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: State.loadData!.password!)
////            let publicKey = KeyGenerator.generatePublicKey(privateKey!)
////            let account_address = AddressGenerator.generateAddress(publicKey)
////            
////            var find = false
////            
////            for suggestion in suggestions {
////                if suggestion.key == account_address {
////                    find = true
////                    break
////                }
////            }
////            
////            if !find {
////                var sugest = NEMTextField.Suggestion()
////                
////                sugest.key = account_address
////                sugest.value = publicKey
////                suggestions.append(sugest)
////                
////                sugest.key = publicKey
////                sugest.value = publicKey
////                suggestions.append(sugest)
////
////            }
////            
////            find = false
////            
////            for suggestion in suggestions {
////                if suggestion.key == wallet.login {
////                    find = true
////                    break
////                }
////            }
////            
////            if !find {
////                var sugest = NEMTextField.Suggestion()
////                
////                sugest.key = wallet.login
////                sugest.value = publicKey
////                suggestions.append(sugest)
////            }
////        }
//        
////        if AddressBookManager.isAllowed ?? false {
////            for contact in AddressBookManager.contacts {
////                var name = ""
////                if contact.givenName != "" {
////                    name = contact.givenName
////                }
////                
////                if contact.familyName != "" {
////                    name += " " + contact.familyName
////                }
////                
////                for email in contact.emailAddresses{
////                    if email.label == "NEM" {
////                        let account_address = email.value as? String ?? " "
////                        
////                        var find = false
////                        
////                        for suggestion in suggestions {
////                            if suggestion.key == account_address {
////                                find = true
////                                break
////                            }
////                        }
////                        if !find {
////                            var sugest = NEMTextField.Suggestion()
////                            sugest.key = account_address
////                            sugest.value = account_address
////                            suggestions.append(sugest)
////                        }
////                        
////                        find = false
////                        
////                        for suggestion in suggestions {
////                            if suggestion.key == name {
////                                find = true
////                                break
////                            }
////                        }
////                        if !find {
////                            var sugest = NEMTextField.Suggestion()
////                            sugest.key = name
////                            sugest.value = account_address
////                            suggestions.append(sugest)
////                        }
////                    }
////                }
////            }
////        }
//        
//        publicKey.suggestions = suggestions
//        publicKey.tableViewMaxRows = 5
//        publicKey.nemDelegate = self
    }
    
    // MARK: View Controller Outlet Actions
    
    @IBAction func addCosignatoryButtonPressed(_ sender: UIButton) {
        
        guard let cosignatoryIdentifier = cosignatoryIdentifierTextField.text else {
            showAlert(withMessage: "FIELDS_EMPTY_ERROR".localized())
            cosignatoryIdentifierTextField.endEditing(true)
            return
        }
        guard cosignatoryIdentifier != "" else {
            showAlert(withMessage: "FIELDS_EMPTY_ERROR".localized())
            cosignatoryIdentifierTextField.endEditing(true)
            return
        }
        
        if TransactionManager.sharedInstance.validateHexadecimalString(cosignatoryIdentifier) == true {
            
            newCosignatoryPublicKey = cosignatoryIdentifier
            performSegue(withIdentifier: "unwindToMultisigViewController", sender: nil)
            
        } else {
            
            if TransactionManager.sharedInstance.validateAccountAddress(cosignatoryIdentifier) == true {
                
                for suggestion in cosignatoryIdentifierTextField.suggestions {
                    if suggestion.key == cosignatoryIdentifier {
                        
                        newCosignatoryPublicKey = suggestion.value
                        performSegue(withIdentifier: "unwindToMultisigViewController", sender: nil)
                    }
                }
                
                showAlert(withMessage: "UNKNOWN_ACCOUNT_ADDRESS".localized())
                cosignatoryIdentifierTextField.endEditing(true)
                return
                
            } else {
                
                showAlert(withMessage: "UNKNOWN_TEXT".localized())
                cosignatoryIdentifierTextField.endEditing(true)
                return
            }
            
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - NEM Text Field Delegate

extension MultisigAddCosignatoryViewController: NEMTextFieldDelegate {
    
    func newNemTexfieldSize(_ size: CGSize) {
        for constraint in contentView.constraints {
            if constraint.identifier == "containerHeight" {
                constraint.constant = size.height + addCosignatoryButton.frame.height
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: - Navigation Bar Delegate

extension MultisigAddCosignatoryViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
