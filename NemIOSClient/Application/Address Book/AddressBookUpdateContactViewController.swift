//
//  AddressBookUpdateContactViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Contacts

protocol AddCustomContactDelegate
{
    func popUpClosed(_ successfuly :Bool)
    func contactAdded(_ successfuly :Bool, sendTransaction :Bool)
    func contactChanged(_ successfuly :Bool, sendTransaction :Bool)
}

class AddressBookUpdateContactViewController: UIViewController, APIManagerDelegate {

    //MARK: - @IBOutlet
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var startConversationSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Properties
    
    var contact :CNContact? = nil
    
    //MARK: - Private variables
    
    fileprivate var _apiManager = APIManager()
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _apiManager.delegate = self
        
        firstName.placeholder = "FIRST_NAME".localized()
        lastName.placeholder = "LAST_NAME".localized()
        address.placeholder = "ADDRESS".localized()
        saveBtn.setTitle("ADD_CONTACT".localized(), for: UIControlState())
        switchLabel.text = "SEND_TRANSACTION_AFTER_ADDING".localized()
        
        let center: NotificationCenter = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(AddressBookUpdateContactViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(AddressBookUpdateContactViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        guard let server = State.currentServer else {
            return
        }
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(server, account_address: account_address)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction

    @IBAction func closePopUp(_ sender: AnyObject) {
//        (self.delegate as! AddCustomContactDelegate).popUpClosed(true)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func addContact(_ sender: UIButton) {
        _changeContact()
    }
    
    @IBAction func textFieldChange(_ sender: UITextField) {
        switch sender {
        case firstName:
            lastName.becomeFirstResponder()
            
        case lastName:
            address.becomeFirstResponder()
            
        default:
            contentView.endEditing(false)
        }
    }
    
    //MARK: - Private Helpers
    
    final fileprivate func _changeContact() {
//        address.text = address.text?.stringByReplacingOccurrencesOfString("-", withString: "")
//        if (Validate.stringNotEmpty(firstName.text) || Validate.stringNotEmpty(lastName.text)) && Validate.address(address.text) {
//            
//            let mutableContact :CNMutableContact = ((self.contact) ?? CNContact()).mutableCopy() as! CNMutableContact
//            
//            mutableContact.givenName = firstName.text!
//            mutableContact.familyName = lastName.text!
//            
//            var newEmails :[CNLabeledValue] = []
//            var find = false
//            
//            for email in mutableContact.emailAddresses {
//                let newEmail = CNLabeledValue(label: email.label, value: (email.label == "NEM") ? address.text! : email.value)
//                newEmails.append(newEmail)
//                
//                if newEmail.value as! String == "NEM" {
//                    find = true
//                }
//            }
//            
//            if !find {
//                let newEmail = CNLabeledValue(label: "NEM", value: address.text!)
//                newEmails.append(newEmail)
//            }
//            
//            mutableContact.emailAddresses = newEmails
//            if self.contact == nil {
//                AddressBookManager.addContact(mutableContact, responce: { (contact) -> Void in
////                    if self.delegate != nil {
////                        
////                        AddressBookViewController.newContact = contact
////                        
////                        dispatch_async(dispatch_get_main_queue(), {
////                            () -> Void in
////                            self.view.removeFromSuperview()
////                            self.removeFromParentViewController()
////                            (self.delegate as! AddCustomContactDelegate).contactAdded(true, sendTransaction: self.startConversationSwitch.on)
////                        })
////                    }
//                    
//                    AddressBookViewController.newContact = contact
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        () -> Void in
//                        self.view.removeFromSuperview()
//                        self.removeFromParentViewController()
////                        (self.delegate as! AddCustomContactDelegate).contactAdded(true, sendTransaction: self.startConversationSwitch.on)
//                    })
//                })
//            } else {
//                AddressBookManager.updateContact(mutableContact, responce: { (contact) -> Void in
////                    if self.delegate != nil {
////                        
////                        AddressBookViewController.newContact = contact
////                        
////                        dispatch_async(dispatch_get_main_queue(), {
////                            () -> Void in
////                            self.view.removeFromSuperview()
////                            self.removeFromParentViewController()
////                            (self.delegate as! AddCustomContactDelegate).contactChanged(true, sendTransaction: self.startConversationSwitch.on)
////                                
////                        })
////                    }
//                    
//                    AddressBookViewController.newContact = contact
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        () -> Void in
//                        self.view.removeFromSuperview()
//                        self.removeFromParentViewController()
////                        (self.delegate as! AddCustomContactDelegate).contactChanged(true, sendTransaction: self.startConversationSwitch.on)
//                        
//                    })
//                })
//            }
//        }
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(_ account: AccountGetMetaData?) {
        startConversationSwitch.isEnabled =  (account?.cosignatories.count ?? 0) == 0
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.scroll.contentInset = UIEdgeInsets.zero
        self.scroll.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
