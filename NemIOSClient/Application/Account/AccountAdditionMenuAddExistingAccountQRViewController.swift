//
//  AccountAdditionMenuAddExistingAccountQRViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The account addition view controller that lets the user add an existing
    account through scanning the qr code for the account.
 */
class AccountAdditionMenuAddExistingAccountQRViewController: UIViewController {
    
    private var _isInited = false
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var qrCodeScannerView: QRCodeScannerView!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    
        updateViewControllerAppearance()
        
        qrCodeScannerView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if !_isInited {
            _isInited = true
            qrCodeScannerView.scanQRCode(qrCodeScannerView.frame.width , height: qrCodeScannerView.frame.height)
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        title = "SCAN_QR_CODE".localized()
    }
}

extension AccountAdditionMenuAddExistingAccountQRViewController: QRCodeScannerDelegate {
    
    func detectedQRCode(withString string: String) {
        
        guard let jsonData = string.dataUsingEncoding(NSUTF8StringEncoding) else {
            qrCodeScannerView.play()
            return
        }
        var jsonStructure :NSDictionary? = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves)) as? NSDictionary
        
        if let version = jsonStructure!.objectForKey(QRKeys.Version.rawValue) as? Int {
            if version != QR_VERSION {
                failedWithError("WRONG_QR_VERSION".localized())
                self.qrCodeScannerView.play()
                return
            }
        } else {
            failedWithError("WRONG_QR_VERSION".localized())
            self.qrCodeScannerView.play()
            return
        }
        
        if jsonStructure == nil {
            qrCodeScannerView.play()
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
            qrCodeScannerView.play()
        }
    }
    
    func failedWithError(error: String) {
        
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
