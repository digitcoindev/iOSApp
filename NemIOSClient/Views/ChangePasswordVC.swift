//
//  ChangePasswordVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 13.01.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class ChangePasswordVC: AbstractViewController {
    @IBOutlet weak var oldPassword: NEMTextField!
    @IBOutlet weak var newPassword: NEMTextField!
    @IBOutlet weak var repeatPassword: NEMTextField!

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    let dataMeneger: CoreDataManager  = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        oldPassword.placeholder = "  " + "OLD_PASSWORD_PLACEHOLDER".localized()
        newPassword.placeholder = "  " + "PASSWORD_PLACEHOLDER".localized()
        repeatPassword.placeholder = "  " + "REPEAT_PASSWORD_PLACEHOLDER".localized()
        
        saveBtn.setTitle("CHANGE".localized(), forState: UIControlState.Normal)
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: #selector(ChangePasswordVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(ChangePasswordVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func changePassword(sender: AnyObject) {
        
        if !Validate.stringNotEmpty(newPassword.text) || !Validate.stringNotEmpty(repeatPassword.text) || !Validate.stringNotEmpty(oldPassword.text){
            _failedWithError("FIELDS_EMPTY_ERROR".localized())
            return
        }
        
        if !Validate.password(newPassword.text!) {
            _failedWithError("PASSOWORD_LENGTH_ERROR".localized())
            repeatPassword.text = ""
            return
        }
        
        if newPassword.text != repeatPassword.text {
            _failedWithError("PASSOWORD_DIFERENCE_ERROR".localized())
            repeatPassword.text = ""
            return
        }
        
        let salt :NSData =  NSData(bytes: State.loadData!.salt!.asByteArray())
        let passwordHashOld :NSData? = try? HashManager.generateAesKeyForString(oldPassword.text!, salt:salt, roundCount:2000)!
        
        if passwordHashOld == nil || passwordHashOld?.hexadecimalString() != State.loadData?.password {
            _failedWithError("WRONG_OLD_PASSWORD".localized())
            oldPassword.text = ""
            return
        }
        
        let passwordHash = try? HashManager.generateAesKeyForString(newPassword.text!, salt:salt, roundCount:2000)!
        
        
        let loadData = dataMeneger.getLoadData()
        loadData.salt = salt.hexadecimalString()
        loadData.password = passwordHash?.hexadecimalString()
        
        for wallet in dataMeneger.getWallets() {
            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: passwordHashOld!.hexadecimalString())
            wallet.privateKey = HashManager.AES256Encrypt(privateKey!, key: loadData.password!)
        }
        
        dataMeneger.commit()
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func changeField(sender: UITextField) {
        switch sender {
        case oldPassword:
            newPassword.becomeFirstResponder()
            
        case newPassword:
            repeatPassword.becomeFirstResponder()
            
        default :
            sender.endEditing(true)
        }
    }
    
    @IBAction func validateField(sender: UITextField){
        
        if repeatPassword.text == newPassword.text {
            repeatPassword.textColor = UIColor.greenColor()
        } else {
            repeatPassword.textColor = UIColor.redColor()
        }
        
        if Validate.password(newPassword.text!){
            newPassword.textColor = UIColor.greenColor()
        } else {
            repeatPassword.textColor = UIColor.redColor()
            newPassword.textColor = UIColor.redColor()
        }
    }
    
    //MARK: - Private Methods
    
    private func _failedWithError(text: String, completion :(Void -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion?()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
