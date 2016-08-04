//
//  AuthenticationPasswordCreationViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AuthenticationPasswordCreationViewController: UIViewController {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var passwordTitle: UILabel!
    
//    let dataMeneger: CoreDataManager  = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTitle.text = "CREATE_PASSWORD".localized()
        password.placeholder = "   " + "PASSWORD_PLACEHOLDER".localized()
        repeatPassword.placeholder = "   " + "REPEAT_PASSWORD_PLACEHOLDER".localized()
        confirm.setTitle("CONFIRM".localized(), forState: UIControlState.Normal)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        State.currentVC = SegueToCreatePassword
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    
    @IBAction func submitPassword(sender: AnyObject) {
        sender.endEditing(true)
        if !Validate.stringNotEmpty(password.text) || !Validate.stringNotEmpty(repeatPassword.text) {
            _failedWithError("FIELDS_EMPTY_ERROR".localized())
            return
        }
        
        if !Validate.password(password.text!) {
            _failedWithError("PASSOWORD_LENGTH_ERROR".localized())
            repeatPassword.text = ""
            return
        }
        
        if password.text != repeatPassword.text {
            _failedWithError("PASSOWORD_DIFERENCE_ERROR".localized())
            repeatPassword.text = ""
            return
        }
        
        let salt :NSData =  NSData().generateRandomIV(32)
        let passwordHash :NSData? = try? HashManager.generateAesKeyForString(password.text!, salt:salt, roundCount:2000)!
        
//        let loadData = dataMeneger.getLoadData()
//        loadData.salt = salt.hexadecimalString()
//        loadData.password = passwordHash?.hexadecimalString()
//        dataMeneger.commit()
        
//        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddAccountVC)
//        }
    }
    
    @IBAction func validateField(sender: UITextField){
        
        if repeatPassword.text == password.text {
            repeatPassword.textColor = UIColor.greenColor()
        } else {
            repeatPassword.textColor = UIColor.redColor()
        }
        
        if Validate.password(password.text!){
            password.textColor = UIColor.greenColor()
        } else {
            repeatPassword.textColor = UIColor.redColor()
            password.textColor = UIColor.redColor()
        }
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject) {
        (sender as! UITextField).becomeFirstResponder()
    }
    
    // MARK: - Private Methods
    
    private func _validateFromDatabase() {
        
        guard let salt = State.loadData?.salt else {return}
        guard let saltData :NSData = NSData.fromHexString(salt) else {return}
        guard let passwordValue = State.loadData?.password else {return}
        
        let passwordData :NSData? = try? HashManager.generateAesKeyForString(password.text!, salt:saltData, roundCount:2000)!
        
        if passwordData?.toHexString() == passwordValue {
            
//            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
//            }
        }
    }
    
    private func _failedWithError(text: String, completion :(Void -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion?()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
