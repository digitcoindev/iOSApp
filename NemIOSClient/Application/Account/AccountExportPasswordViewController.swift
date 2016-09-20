//
//  AccountExportPasswordViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AccountExportPasswordViewController: UIViewController
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordSwitch: UISwitch!
    
//    let dataMeneger: CoreDataManager  = CoreDataManager()
    
    // MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        State.currentVC = SegueToPasswordExport
        
        passwordTitle.text = "ENTET_PASSWORD_EXPORT".localized()
        password.placeholder = "PASSWORD_PLACEHOLDER".localized()
        passwordLabel.text = "PASSWORD_PLACEHOLDER_EXPORT".localized()
        confirm.setTitle("CONFIRM".localized(), for: UIControlState())
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        State.currentVC = SegueToPasswordExport
    }
    
    // MARK: - IBAction
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        var height :CGFloat = 0
        
        if sender.isOn {
            height = 100
            password.text = ""
            password.endEditing(true)
        } else {
            height = 152
        }
        
        for constraint in containerView.constraints {
            if constraint.identifier == "height" {
                constraint.constant = height
                break
            }
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    @IBAction func passwordValidation(_ sender: AnyObject) {
        password.endEditing(true)
        
        _prepareForExport()
    }
    
    @IBAction func hideKeyBoard(_ sender: AnyObject) {
        (sender as! UITextField).becomeFirstResponder()
    }
    // MARK: - Private Methods
    
    fileprivate func _prepareForExport() {
        
        if !passwordSwitch.isOn && !Validate.stringNotEmpty(password.text){
            _failedWithError("FIELDS_EMPTY_ERROR".localized())
            return
        }
        
        if !passwordSwitch.isOn && !Validate.password(password.text!) {
            _failedWithError("PASSOWORD_LENGTH_ERROR".localized())
            return
        }
        
        let login = State.currentWallet!.login
        
        let salt = State.loadData!.salt!
        var privateKey_AES = State.currentWallet!.privateKey
        
        if password.text != "" {
            let privateKey = HashManager.AES256Decrypt(privateKey_AES, key: State.loadData!.password!)
            let saltData = Data(bytes: salt.asByteArray())
            let passwordHash :Data? = try! HashManager.generateAesKeyForString(password.text!, salt:saltData as NSData, roundCount:2000)! as Data?
            privateKey_AES = HashManager.AES256Encrypt(privateKey!, key: passwordHash!.hexadecimalString())
        }
        
        let objects = [login, salt, privateKey_AES]
        let keys = [QRKeys.Name.rawValue, QRKeys.Salt.rawValue, QRKeys.PrivateKey.rawValue]
        
        let jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects, forKeys: keys as [NSCopying])
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.accountData.rawValue, jsonAccountDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue as NSCopying, QRKeys.Data.rawValue as NSCopying, QRKeys.Version.rawValue as NSCopying])
        let jsonData :Data = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions())
        let jsonString :String = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String
        
        State.exportAccount = jsonString
        
//        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
//            (self.delegate as! MainVCDelegate).pageSelected(SegueToExportAccount)
//        }
        
        performSegue(withIdentifier: "showAccountExportViewController", sender: nil)
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
