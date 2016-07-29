//
//  AccountAddExistingQRViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AccountAddExistingQRViewController: UIViewController, QRDelegate
{
    //MARK: - IBOulets

    @IBOutlet weak var screenScaner: QRCodeScannerView!
    
    private var _isInited = false

    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    
        screenScaner.delegate = self
        
        title = "SCAN_QR_CODE".localized()
    }
    
    override func viewDidAppear(animated: Bool) {
        if !_isInited {
            _isInited = true
            screenScaner.scanQR(screenScaner.frame.width , height: screenScaner.frame.height )
        }
        
//        State.currentVC = SegueToImportFromQR
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: - QRDelegate Methods
    
    func detectedQRWithString(text: String) {
        guard let jsonData = text.dataUsingEncoding(NSUTF8StringEncoding) else {
            screenScaner.play()
            return
        }
        var jsonStructure :NSDictionary? = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves)) as? NSDictionary

        if let version = jsonStructure!.objectForKey(QRKeys.Version.rawValue) as? Int {
            if version != QR_VERSION {
                failedWithError("WRONG_QR_VERSION".localized()) {
                    self.screenScaner.play()
                }
                
                return
            }
        } else {
            failedWithError("WRONG_QR_VERSION".localized()) {
                self.screenScaner.play()
            }
            
            return
        }
        
        if jsonStructure == nil {
            screenScaner.play()
        }
        else if jsonStructure!.objectForKey(QRKeys.DataType.rawValue) as! Int == QRType.AccountData.rawValue {
            jsonStructure = jsonStructure!.objectForKey(QRKeys.Data.rawValue) as? NSDictionary
            
            if jsonStructure != nil {
                let privateKey_AES = jsonStructure!.objectForKey(QRKeys.PrivateKey.rawValue) as! String
                let login = jsonStructure!.objectForKey(QRKeys.Name.rawValue) as! String
                let salt = jsonStructure!.objectForKey(QRKeys.Salt.rawValue) as! String
                let saltBytes = salt.asByteArray()
                let saltData = NSData(bytes: saltBytes, length: saltBytes.count)
                
//                State.fromVC = SegueToImportFromQR
//                State.nextVC = SegueToLoginVC
                
                State.importAccountData = {
                    (password) -> Bool in
                    
                    guard let passwordHash :NSData? = try? HashManager.generateAesKeyForString(password, salt:saltData, roundCount:2000) else {return false}
                    guard let privateKey :String = HashManager.AES256Decrypt(privateKey_AES, key: passwordHash!.toHexString()) else {return false}
                    guard let normalizedKey = privateKey.nemKeyNormalized() else { return false }
                    
                    if let name = Validate.account(privateKey: normalizedKey) {
                        let alert = UIAlertView(title: "VALIDATION".localized(), message: String(format: "VIDATION_ACCOUNT_EXIST".localized(), arguments:[name]), delegate: self, cancelButtonTitle: "OK".localized())
                        alert.show()

                        return true
                    }
                    
                    WalletGenerator().createWallet(login, privateKey: normalizedKey)
                    
                    return true
                }
                
                performSegueWithIdentifier("showAccountPasswordValidationViewController", sender: nil)
            }
        }
        else {
            screenScaner.play()
        }
    }
    
    func failedWithError(text: String, completion :(Void -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion?()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
