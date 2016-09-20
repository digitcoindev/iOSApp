//
//  SettingsChangePasswordViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class SettingsChangePasswordViewController: UIViewController {
    @IBOutlet weak var oldPassword: NEMTextField!
    @IBOutlet weak var newPassword: NEMTextField!
    @IBOutlet weak var repeatPassword: NEMTextField!

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
//    let dataMeneger: CoreDataManager  = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        oldPassword.placeholder = "  " + "OLD_PASSWORD_PLACEHOLDER".localized()
        newPassword.placeholder = "  " + "PASSWORD_PLACEHOLDER".localized()
        repeatPassword.placeholder = "  " + "REPEAT_PASSWORD_PLACEHOLDER".localized()
        
        saveBtn.setTitle("CHANGE".localized(), for: UIControlState())
        
        let center: NotificationCenter = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(SettingsChangePasswordViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(SettingsChangePasswordViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(_ sender: AnyObject) {        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func changePassword(_ sender: AnyObject) {
        
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
        
        let salt :Data =  Data(bytes: State.loadData!.salt!.asByteArray())
        let passwordHashOld :Data? = try! HashManager.generateAesKeyForString(oldPassword.text!, salt:salt as NSData, roundCount:2000)! as Data?
        
        if passwordHashOld == nil || passwordHashOld?.hexadecimalString() != State.loadData?.password {
            _failedWithError("WRONG_OLD_PASSWORD".localized())
            oldPassword.text = ""
            return
        }
        
        let passwordHash = try? HashManager.generateAesKeyForString(newPassword.text!, salt:salt as NSData, roundCount:2000)!
        
        
//        let loadData = dataMeneger.getLoadData()
//        loadData.salt = salt.hexadecimalString()
//        loadData.password = passwordHash?.hexadecimalString()
//        
//        for wallet in dataMeneger.getWallets() {
//            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: passwordHashOld!.hexadecimalString())
//            wallet.privateKey = HashManager.AES256Encrypt(privateKey!, key: loadData.password!)
//        }
//        
//        dataMeneger.commit()
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func changeField(_ sender: UITextField) {
        switch sender {
        case oldPassword:
            newPassword.becomeFirstResponder()
            
        case newPassword:
            repeatPassword.becomeFirstResponder()
            
        default :
            sender.endEditing(true)
        }
    }
    
    @IBAction func validateField(_ sender: UITextField){
        
        if repeatPassword.text == newPassword.text {
            repeatPassword.textColor = UIColor.green
        } else {
            repeatPassword.textColor = UIColor.red
        }
        
        if Validate.password(newPassword.text!){
            newPassword.textColor = UIColor.green
        } else {
            repeatPassword.textColor = UIColor.red
            newPassword.textColor = UIColor.red
        }
    }
    
    //MARK: - Private Methods
    
    fileprivate func _failedWithError(_ text: String, completion :((Void) -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        self.present(alert, animated: true, completion: nil)
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
