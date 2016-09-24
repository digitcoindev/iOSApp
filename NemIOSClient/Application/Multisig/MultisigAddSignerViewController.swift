//
//  MultisigAddSignerViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/// The view controller that lets the user add a new multisig cosigner.
class MultisigAddSignerViewController: UIViewController, NEMTextFieldDelegate {
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var publicKey: NEMTextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.delegate = self
        
        updateViewControllerAppearance()
        
        _setSuggestions()
        
        let center: NotificationCenter = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(MultisigAddSignerViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(MultisigAddSignerViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewTopConstraint.constant = self.navigationBar.frame.height
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        customNavigationItem.title = "ADD_COSIGNATORY".localized()
        publicKey.placeholder = "   " + "INPUT_PUBLIC_KEY".localized()
        saveBtn.setTitle("ADD_COSIGNATORY".localized(), for: UIControlState())
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    fileprivate func _setSuggestions() {
        let suggestions :[NEMTextField.Suggestion] = []
//        let dataManager = CoreDataManager()
        
//        for wallet in dataManager.getWallets() {
//            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: State.loadData!.password!)
//            let publicKey = KeyGenerator.generatePublicKey(privateKey!)
//            let account_address = AddressGenerator.generateAddress(publicKey)
//            
//            var find = false
//            
//            for suggestion in suggestions {
//                if suggestion.key == account_address {
//                    find = true
//                    break
//                }
//            }
//            
//            if !find {
//                var sugest = NEMTextField.Suggestion()
//                
//                sugest.key = account_address
//                sugest.value = publicKey
//                suggestions.append(sugest)
//                
//                sugest.key = publicKey
//                sugest.value = publicKey
//                suggestions.append(sugest)
//
//            }
//            
//            find = false
//            
//            for suggestion in suggestions {
//                if suggestion.key == wallet.login {
//                    find = true
//                    break
//                }
//            }
//            
//            if !find {
//                var sugest = NEMTextField.Suggestion()
//                
//                sugest.key = wallet.login
//                sugest.value = publicKey
//                suggestions.append(sugest)
//            }
//        }
        
//        if AddressBookManager.isAllowed ?? false {
//            for contact in AddressBookManager.contacts {
//                var name = ""
//                if contact.givenName != "" {
//                    name = contact.givenName
//                }
//                
//                if contact.familyName != "" {
//                    name += " " + contact.familyName
//                }
//                
//                for email in contact.emailAddresses{
//                    if email.label == "NEM" {
//                        let account_address = email.value as? String ?? " "
//                        
//                        var find = false
//                        
//                        for suggestion in suggestions {
//                            if suggestion.key == account_address {
//                                find = true
//                                break
//                            }
//                        }
//                        if !find {
//                            var sugest = NEMTextField.Suggestion()
//                            sugest.key = account_address
//                            sugest.value = account_address
//                            suggestions.append(sugest)
//                        }
//                        
//                        find = false
//                        
//                        for suggestion in suggestions {
//                            if suggestion.key == name {
//                                find = true
//                                break
//                            }
//                        }
//                        if !find {
//                            var sugest = NEMTextField.Suggestion()
//                            sugest.key = name
//                            sugest.value = account_address
//                            suggestions.append(sugest)
//                        }
//                    }
//                }
//            }
//        }
        
        publicKey.suggestions = suggestions
        publicKey.tableViewMaxRows = 5
        publicKey.nemDelegate = self
    }
    
    // MARK: View Controller Outlet Actions
    
    @IBAction func addCosig(_ sender: AnyObject) {
//        if !Validate.stringNotEmpty(publicKey.text) {
//            errorLabel.text = "FIELDS_EMPTY_ERROR".localized()
//            errorLabel.isHidden = false
//            publicKey.endEditing(true)
//            return
//        }
//        
//        if Validate.hexString(publicKey.text!){
////            (self.delegate as? AddCosigPopUptDelegate)?.addCosig(publicKey.text!)
//            self.view.removeFromSuperview()
//            self.removeFromParentViewController()
//        } else {
//            if  Validate.address(publicKey.text!) {
//                for suggestion in  publicKey.suggestions {
//                    if suggestion.key == publicKey.text {
////                        (self.delegate as? AddCosigPopUptDelegate)?.addCosig(publicKey.text!)
//                        
//                        self.view.removeFromSuperview()
//                        self.removeFromParentViewController()
//                        return
//                    }
//                }
//                
//                errorLabel.text = "UNKNOWN_ACCOUNT_ADDRESS".localized()
//            } else {
//                errorLabel.text = "UNKNOWN_TEXT".localized()
//            }
//            
//            errorLabel.isHidden = false
//            publicKey.endEditing(true)
//        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - NEMTextFieldDelegate Methods
    
    func newNemTexfieldSize(_ size: CGSize) {
        for constraint in contentView.constraints {
            if constraint.identifier == "containerHeight" {
                constraint.constant = size.height + saveBtn.frame.height
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsets.zero
        scroll.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.scroll.contentInset = UIEdgeInsets.zero
        self.scroll.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

// MARK: - Navigation Bar Delegate

extension MultisigAddSignerViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
