//
//  AddCustomContactVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 05.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit
import AddressBook

protocol AddCustomContactDelegate
{
    func contactAdded(successfuly :Bool)
    func contactChanged(successfuly :Bool)
}

class AddCustomContactVC: AbstractViewController {

    //MARK: - @IBOutlet
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var address: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Properties
    
    var contact :ABRecordRef? = nil
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction

    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func addContact(sender: UIButton) {
        if contact == nil {
        _addContact()
        } else {
            _changeContact()
        }
    }
    
    @IBAction func textFieldChange(sender: UITextField) {
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
    
    final private func _changeContact() {
        if Validate.stringNotEmpty(firstName.text) && Validate.stringNotEmpty(lastName.text) && Validate.address(address.text) {
            AddressBookManager.changeContact(self.contact!, address: address.text!, name: firstName.text!, surname: lastName.text!, responce: { () -> Void in
                if self.delegate != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.view.removeFromSuperview()
                        self.removeFromParentViewController()
                        (self.delegate as! AddCustomContactDelegate).contactAdded(true)
                    })
                }
            })
        }
    }
    
    final private func _addContact() {
        if Validate.stringNotEmpty(firstName.text) && Validate.stringNotEmpty(lastName.text) && Validate.address(address.text) {
            AddressBookManager.addContact(firstName.text!, surname: lastName.text!, address: address.text!){
                () -> Void in
                
                if self.delegate != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.view.removeFromSuperview()
                        self.removeFromParentViewController()
                        (self.delegate as! AddCustomContactDelegate).contactAdded(true)
                    })
                }
            }
        }
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
