//
//  InvoiceScanViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import AddressBook
import AddressBookUI

class InvoiceScanViewController: UIViewController, QRCodeScannerDelegate, AddCustomContactDelegate
{
    @IBOutlet weak var qrScaner: QRCodeScannerView!
    
    fileprivate var _tempController: UIViewController? = nil
    fileprivate var _isInited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        State.fromVC = SegueToScanQR

        qrScaner.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        if !_isInited {
            _isInited = true
            qrScaner.scanQRCode(qrScaner.frame.width , height: qrScaner.frame.height )
        }
//        State.currentVC = SegueToScanQR
    }

    func detectedQRCode(withCaptureResult text: String) {
        let base64String :String = text
        if base64String != "Empty scan" {
            let jsonData :Data = text.data(using: String.Encoding.utf8)!
            var jsonStructure :NSDictionary? = nil

            jsonStructure = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSDictionary

            if jsonStructure == nil {
                qrScaner.captureSession.startRunning()
                return 
            }
            
            
            if let version = jsonStructure!.object(forKey: QRKeys.Version.rawValue) as? Int {
                if version != QR_VERSION {
                    failedDetectingQRCode(withError: "WRONG_QR_VERSION".localized())
                    self.qrScaner.captureSession.startRunning()
                    
                    return
                }
            } else {
                failedDetectingQRCode(withError: "WRONG_QR_VERSION".localized())
                self.qrScaner.captureSession.startRunning()
                return
            }
            
            switch (jsonStructure!.object(forKey: QRKeys.DataType.rawValue) as! Int) {
            case QRType.userData.rawValue:
                
                let friendDictionary :NSDictionary = jsonStructure!.object(forKey: QRKeys.Data.rawValue) as! NSDictionary
                
//                if (AddressBookManager.isAllowed ?? false) {
//                    addFriend(friendDictionary)
//                }
//                else {
//                    failedDetectingQRCode(withError: "CONTACTS_IS_UNAVAILABLE".localized())
//                }
                
            case QRType.invoice.rawValue:
                
                let invoiceDictionary :NSDictionary = jsonStructure!.object(forKey: QRKeys.Data.rawValue) as! NSDictionary
                
                performInvoice(invoiceDictionary)
                
            case QRType.accountData.rawValue:
                jsonStructure = jsonStructure!.object(forKey: QRKeys.Data.rawValue) as? NSDictionary
                
                if jsonStructure != nil {
                    let privateKey_AES = jsonStructure!.object(forKey: QRKeys.PrivateKey.rawValue) as! String
                    let login = jsonStructure!.object(forKey: QRKeys.Name.rawValue) as! String
                    let salt = jsonStructure!.object(forKey: QRKeys.Salt.rawValue) as! String
                    let saltBytes = salt.asByteArray()
                    let saltData = Data(bytes: UnsafePointer<UInt8>(saltBytes), count: saltBytes.count)
                    
//                    State.nextVC = SegueToLoginVC
                    State.importAccountData = {
                        (password) -> Bool in
                        
                        guard let passwordHash :Data? = try? HashManager.generateAesKeyForString(password, salt:saltData, roundCount:2000) else {return false}
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
                    
//                    if (self.delegate as? AbstractViewController)?.delegate != nil && (self.delegate as! AbstractViewController).delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                        ((self.delegate as! AbstractViewController).delegate as! MainVCDelegate).pageSelected(SegueToPasswordValidation)
//                    }
                }
            default :
                qrScaner.captureSession.startRunning()
                break
            }
        }
    }
    
    func failedDetectingQRCode(withError errorMessage: String) {

        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    final func detectedQR(_ notification: Notification) {
            }
    
    final func performInvoice(_ invoiceDictionary :NSDictionary) {
        var invoice :InvoiceData = InvoiceData()
        
        invoice.address = invoiceDictionary.object(forKey: QRKeys.Address.rawValue) as! String
        invoice.name = invoiceDictionary.object(forKey: QRKeys.Name.rawValue) as! String
        invoice.amount = invoiceDictionary.object(forKey: QRKeys.Amount.rawValue) as! Double / 1000000
        invoice.message = invoiceDictionary.object(forKey: QRKeys.Message.rawValue) as! String
        
        State.invoice = invoice
        
        if State.invoice != nil {
//            let navDelegate = (self.delegate as? InvoiceViewController)?.delegate as? MainVCDelegate
//            if navDelegate != nil  {
//                navDelegate!.pageSelected(SegueToSendTransaction)
//            }
            
            performSegue(withIdentifier: "showTransactionSendViewController", sender: nil)
        }

    }
    
    final func addFriend(_ friendDictionary :NSDictionary) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddressBookUpdateContactViewController =  storyboard.instantiateViewController(withIdentifier: "AddressBookAddContactViewController") as! AddressBookUpdateContactViewController
        contactCustomVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        contactCustomVC.view.layer.opacity = 0
//        contactCustomVC.delegate = self
        
        contactCustomVC.firstName.text = friendDictionary.object(forKey: QRKeys.Name.rawValue) as? String
        contactCustomVC.lastName.text = friendDictionary.object(forKey: "surname") as? String
        contactCustomVC.address.text = friendDictionary.object(forKey: QRKeys.Address.rawValue) as? String
        _tempController = contactCustomVC
        
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)

    }
  
    // MARK: -  AddCustomContactDelegate

    func contactAdded(_ successfuly: Bool, sendTransaction :Bool) {
        if successfuly {
//            let navDelegate = (self.delegate as? InvoiceViewController)?.delegate as? MainVCDelegate
//            if navDelegate != nil  {
//                if sendTransaction {
//                    let correspondent :Correspondent = Correspondent()
//                    
//                    for email in AddressBookViewController.newContact!.emailAddresses{
//                        if email.label == "NEM" {
//                            correspondent.address = (email.value as? String) ?? " "
//                            correspondent.name = correspondent.address.nemName()
//                        }
//                    }
//                    State.currentContact = correspondent
//                }
//                navDelegate!.pageSelected(sendTransaction ? SegueToSendTransaction : SegueToAddressBook)
//            }
        }
    }
    
    func popUpClosed(_ successfuly :Bool) {
        qrScaner.captureSession.startRunning()
    }
    
    func contactChanged(_ successfuly: Bool, sendTransaction :Bool) {

    }
}
