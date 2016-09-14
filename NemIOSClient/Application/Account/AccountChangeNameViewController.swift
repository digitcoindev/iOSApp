//
//  AccountChangeNameViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

protocol ChangeNamePopUptDelegate
{
    func nameChanged(_ name :String)
    func popUpClosed()
}

class AccountChangeNameViewController: UIViewController {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var newName: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newName.placeholder = "   " + "INPUT_NEW_ACCOUNT_NAME".localized()
        saveBtn.setTitle("CHANGE".localized(), for: UIControlState())
        
        let center: NotificationCenter = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(AccountChangeNameViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(AccountChangeNameViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(_ sender: AnyObject) {
//        (self.delegate as! ChangeNamePopUptDelegate).popUpClosed()
    }
    
    @IBAction func didEndEditingOnWxit(_ sender: UITextField) {
        sender.endEditing(true)
    }
    
    @IBAction func changeName(_ sender: AnyObject) {
        if Validate.stringNotEmpty(newName.text) {
//            nameChanged(newName.text!)
//            (self.delegate as! ChangeNamePopUptDelegate).popUpClosed()
        }
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
