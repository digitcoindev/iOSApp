//
//  MultisigAddSignerViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

protocol AddCosigPopUptDelegate
{
    func addCosig(_ publicKey :String)
}

class MultisigAddSignerViewController: UIViewController, NEMTextFieldDelegate {
    
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
        saveBtn.setTitle("ADD_COSIGNATORY".localized(), for: UIControlState())
        
        let center: NotificationCenter = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(MultisigAddSignerViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(MultisigAddSignerViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        errorLabel.layer.cornerRadius = 5
        errorLabel.clipsToBounds = true
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func addCosig(_ sender: AnyObject) {
        if !Validate.stringNotEmpty(publicKey.text) {
            errorLabel.text = "FIELDS_EMPTY_ERROR".localized()
            errorLabel.isHidden = false
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
            
            errorLabel.isHidden = false
            publicKey.endEditing(true)
        }
    }
    
    @IBAction func textFieldEditingDidBegin(_ sender: AnyObject) {
        errorLabel.text = ""
        errorLabel.isHidden = true
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

