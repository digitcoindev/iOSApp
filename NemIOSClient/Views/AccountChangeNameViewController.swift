//
//  ChangeNamePopUp.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 26.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

protocol ChangeNamePopUptDelegate
{
    func nameChanged(name :String)
    func popUpClosed()
}

class AccountChangeNameViewController: AbstractViewController {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var newName: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newName.placeholder = "   " + "INPUT_NEW_ACCOUNT_NAME".localized()
        saveBtn.setTitle("CHANGE".localized(), forState: UIControlState.Normal)
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: #selector(AccountChangeNameViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(AccountChangeNameViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        (self.delegate as! ChangeNamePopUptDelegate).popUpClosed()
    }
    
    @IBAction func didEndEditingOnWxit(sender: UITextField) {
        sender.endEditing(true)
    }
    
    @IBAction func changeName(sender: AnyObject) {
        if Validate.stringNotEmpty(newName.text) {
            (self.delegate as! ChangeNamePopUptDelegate).nameChanged(newName.text!)
            (self.delegate as! ChangeNamePopUptDelegate).popUpClosed()
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