//
//  PasswordExportVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 02.02.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class PasswordExportVC: AbstractViewController
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordSwitch: UISwitch!
    
    let dataMeneger: CoreDataManager  = CoreDataManager()
    
    // MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToPasswordValidation
        
        passwordTitle.text = "ENTET_PASSWORD_EXPORT".localized()
        password.placeholder = "PASSWORD_PLACEHOLDER".localized()
        passwordLabel.text = "PASSWORD_PLACEHOLDER_EXPORT".localized()
        confirm.setTitle("CONFIRM".localized(), forState: UIControlState.Normal)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    // MARK: - IBAction
    
    @IBAction func switchChanged(sender: UISwitch) {
        var height :CGFloat = 0
        
        if sender.on {
            height = 100
            password.text = ""
            password.endEditing(true)
        } else {
            height = 152
        }
        
        for constraint in containerView.constraints {
            if constraint.identifier == "height" {
                constraint.constant = height
            }
        }
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func passwordValidation(sender: AnyObject) {
        password.endEditing(true)
        
        _prepareForExport()
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject) {
        (sender as! UITextField).becomeFirstResponder()
    }
    // MARK: - Private Methods
    
    private func _prepareForExport() {
        
        if !passwordSwitch.on && !Validate.stringNotEmpty(password.text){
            var alert :UIAlertView!
            alert  = UIAlertView(title: "VALIDATION".localized(), message: "FIELDS_EMPTY_ERROR".localized(), delegate: self, cancelButtonTitle: "OK".localized())
            alert.show()
            return
        }
        
        let login = State.currentWallet!.login
        
        let salt = State.loadData!.salt!
        var privateKey_AES = State.currentWallet!.privateKey
        
        if password.text != "" {
            let privateKey = HashManager.AES256Decrypt(privateKey_AES, key: State.loadData!.password!)
            let saltData = NSData(bytes: salt.asByteArray())
            let passwordHash :NSData? = try? HashManager.generateAesKeyForString(password.text!, salt:saltData, roundCount:2000)!
            privateKey_AES = HashManager.AES256Encrypt(privateKey!, key: passwordHash!.hexadecimalString())
        }
        
        let objects = [login, salt, privateKey_AES]
        let keys = [QRKeys.Name.rawValue, QRKeys.Salt.rawValue, QRKeys.PrivateKey.rawValue]
        
        let jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects, forKeys: keys)
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.AccountData.rawValue, jsonAccountDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue, QRKeys.Version.rawValue])
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        let jsonString :String = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
        State.exportAccount = jsonString
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
        }
    }
}