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
        confirm.setTitle("CONFIRM".localized(), for: UIControlState())
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        State.currentVC = SegueToCreatePassword
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    
    @IBAction func submitPassword(_ sender: AnyObject) {
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
        
        let salt :Data =  (Data() as NSData).generateRandomIV(32)
        let passwordHash :Data? = try? HashManager.generateAesKeyForString(password.text!, salt:salt, roundCount:2000)!
        
//        let loadData = dataMeneger.getLoadData()
//        loadData.salt = salt.hexadecimalString()
//        loadData.password = passwordHash?.hexadecimalString()
//        dataMeneger.commit()
        
//        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddAccountVC)
//        }
    }
    
    @IBAction func validateField(_ sender: UITextField){
        
        if repeatPassword.text == password.text {
            repeatPassword.textColor = UIColor.green
        } else {
            repeatPassword.textColor = UIColor.red
        }
        
        if Validate.password(password.text!){
            password.textColor = UIColor.green
        } else {
            repeatPassword.textColor = UIColor.red
            password.textColor = UIColor.red
        }
    }
    
    @IBAction func hideKeyBoard(_ sender: AnyObject) {
        (sender as! UITextField).becomeFirstResponder()
    }
    
    // MARK: - Private Methods
    
    fileprivate func _validateFromDatabase() {
        
        guard let salt = State.loadData?.salt else {return}
        guard let saltData :Data = Data.fromHexString(salt) else {return}
        guard let passwordValue = State.loadData?.password else {return}
        
        let passwordData :Data? = try? HashManager.generateAesKeyForString(password.text!, salt:saltData, roundCount:2000)!
        
        if passwordData?.toHexString() == passwordValue {
            
//            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
//            }
        }
    }
    
    fileprivate func _failedWithError(_ text: String, completion :((Void) -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
