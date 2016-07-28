//
//  AddCosigPopUp.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 23.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

protocol AddCosigPopUptDelegate
{
    func addCosig(publicKey :String)
}

class MultisignatureAddSignerViewController: UIViewController, NEMTextFieldDelegate {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var publicKey: NEMTextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicKey.placeholder = "   " + "INPUT_PUBLIC_KEY".localized()
        _setSuggestions()
        saveBtn.setTitle("ADD_COSIGNATORY".localized(), forState: UIControlState.Normal)
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: #selector(MultisignatureAddSignerViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(MultisignatureAddSignerViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        errorLabel.layer.cornerRadius = 5
        errorLabel.clipsToBounds = true
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func _setSuggestions() {
        var suggestions :[NEMTextField.Suggestion] = []
        let dataManager = CoreDataManager()
        
        for wallet in dataManager.getWallets() {
            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: State.loadData!.password!)
            let publicKey = KeyGenerator.generatePublicKey(privateKey!)
            let account_address = AddressGenerator.generateAddress(publicKey)
            
            var find = false
            
            for suggestion in suggestions {
                if suggestion.key == account_address {
                    find = true
                    break
                }
            }
            
            if !find {
                var sugest = NEMTextField.Suggestion()
                
                sugest.key = account_address
                sugest.value = publicKey
                suggestions.append(sugest)
                
                sugest.key = publicKey
                sugest.value = publicKey
                suggestions.append(sugest)

            }
            
            find = false
            
            for suggestion in suggestions {
                if suggestion.key == wallet.login {
                    find = true
                    break
                }
            }
            
            if !find {
                var sugest = NEMTextField.Suggestion()
                
                sugest.key = wallet.login
                sugest.value = publicKey
                suggestions.append(sugest)
            }
        }
        
        if AddressBookManager.isAllowed ?? false {
            for contact in AddressBookManager.contacts {
                var name = ""
                if contact.givenName != "" {
                    name = contact.givenName
                }
                
                if contact.familyName != "" {
                    name += " " + contact.familyName
                }
                
                for email in contact.emailAddresses{
                    if email.label == "NEM" {
                        let account_address = email.value as? String ?? " "
                        
                        var find = false
                        
                        for suggestion in suggestions {
                            if suggestion.key == account_address {
                                find = true
                                break
                            }
                        }
                        if !find {
                            var sugest = NEMTextField.Suggestion()
                            sugest.key = account_address
                            sugest.value = account_address
                            suggestions.append(sugest)
                        }
                        
                        find = false
                        
                        for suggestion in suggestions {
                            if suggestion.key == name {
                                find = true
                                break
                            }
                        }
                        if !find {
                            var sugest = NEMTextField.Suggestion()
                            sugest.key = name
                            sugest.value = account_address
                            suggestions.append(sugest)
                        }
                    }
                }
            }
        }
        
        publicKey.suggestions = suggestions
        publicKey.tableViewMaxRows = 5
        publicKey.nemDelegate = self
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func addCosig(sender: AnyObject) {
        if !Validate.stringNotEmpty(publicKey.text) {
            errorLabel.text = "FIELDS_EMPTY_ERROR".localized()
            errorLabel.hidden = false
            publicKey.endEditing(true)
            return
        }
        
        if Validate.hexString(publicKey.text!){
//            (self.delegate as? AddCosigPopUptDelegate)?.addCosig(publicKey.text!)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        } else {
            if  Validate.address(publicKey.text!) {
                for suggestion in  publicKey.suggestions {
                    if suggestion.key == publicKey.text {
//                        (self.delegate as? AddCosigPopUptDelegate)?.addCosig(publicKey.text!)
                        
                        self.view.removeFromSuperview()
                        self.removeFromParentViewController()
                        return
                    }
                }
                
                errorLabel.text = "UNKNOWN_ACCOUNT_ADDRESS".localized()
            } else {
                errorLabel.text = "UNKNOWN_TEXT".localized()
            }
            
            errorLabel.hidden = false
            publicKey.endEditing(true)
        }
    }
    
    @IBAction func textFieldEditingDidBegin(sender: AnyObject) {
        errorLabel.text = ""
        errorLabel.hidden = true
    }
    
    //MARK: - NEMTextFieldDelegate Methods
    
    func newNemTexfieldSize(size: CGSize) {
        for constraint in contentView.constraints {
            if constraint.identifier == "containerHeight" {
                constraint.constant = size.height + saveBtn.frame.height
            }
        }
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsZero
        scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}

