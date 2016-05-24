import UIKit
import AddressBook
import AddressBookUI

class ScanQRVC: AbstractViewController, QRDelegate, AddCustomContactDelegate
{
    @IBOutlet weak var qrScaner: QR!
    
    private var _tempController: AbstractViewController? = nil
    private var _isInited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        State.fromVC = SegueToScanQR

        qrScaner.delegate = self
    }
    override func viewDidAppear(animated: Bool) {
        if !_isInited {
            _isInited = true
            qrScaner.scanQR(qrScaner.frame.width , height: qrScaner.frame.height )
        }
        State.currentVC = SegueToScanQR
    }

    func detectedQRWithString(text: String) {
        let base64String :String = text
        if base64String != "Empty scan" {
            let jsonData :NSData = text.dataUsingEncoding(NSUTF8StringEncoding)!
            var jsonStructure :NSDictionary? = nil

            jsonStructure = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves)) as? NSDictionary

            if jsonStructure == nil {
                qrScaner.play()
                return 
            }
            
            
            if let version = jsonStructure!.objectForKey(QRKeys.Version.rawValue) as? Int {
                if version != QR_VERSION {
                    failedWithError("WRONG_QR_VERSION".localized()) {
                        self.qrScaner.play()
                    }
                    
                    return
                }
            } else {
                failedWithError("WRONG_QR_VERSION".localized()) {
                    self.qrScaner.play()
                }

                return
            }
            
            switch (jsonStructure!.objectForKey(QRKeys.DataType.rawValue) as! Int) {
            case QRType.UserData.rawValue:
                
                let friendDictionary :NSDictionary = jsonStructure!.objectForKey(QRKeys.Data.rawValue) as! NSDictionary
                
                if (AddressBookManager.isAllowed ?? false) {
                    addFriend(friendDictionary)
                }
                else {
                    failedWithError("CONTACTS_IS_UNAVAILABLE".localized())
                }
                
            case QRType.Invoice.rawValue:
                
                let invoiceDictionary :NSDictionary = jsonStructure!.objectForKey(QRKeys.Data.rawValue) as! NSDictionary
                
                performInvoice(invoiceDictionary)
                
            case QRType.AccountData.rawValue:
                jsonStructure = jsonStructure!.objectForKey(QRKeys.Data.rawValue) as? NSDictionary
                
                if jsonStructure != nil {
                    let privateKey_AES = jsonStructure!.objectForKey(QRKeys.PrivateKey.rawValue) as! String
                    let login = jsonStructure!.objectForKey(QRKeys.Name.rawValue) as! String
                    let salt = jsonStructure!.objectForKey(QRKeys.Salt.rawValue) as! String
                    let saltBytes = salt.asByteArray()
                    let saltData = NSData(bytes: saltBytes, length: saltBytes.count)
                    
                    State.nextVC = SegueToLoginVC
                    State.importAccountData = {
                        (password) -> Bool in
                        
                        guard let passwordHash :NSData? = try? HashManager.generateAesKeyForString(password, salt:saltData, roundCount:2000) else {return false}
                        guard let privateKey :String = HashManager.AES256Decrypt(privateKey_AES, key: passwordHash!.toHexString()) else {return false}
                        
                        WalletGenerator().createWallet(login, privateKey: privateKey)
                        
                        return true
                    }
                    
                    if (self.delegate as? AbstractViewController)?.delegate != nil && (self.delegate as! AbstractViewController).delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                        ((self.delegate as! AbstractViewController).delegate as! MainVCDelegate).pageSelected(SegueToPasswordValidation)
                    }
                }
            default :
                qrScaner.play()
                break
            }
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
    
    final func detectedQR(notification: NSNotification) {
            }
    
    final func performInvoice(invoiceDictionary :NSDictionary) {
        var invoice :InvoiceData = InvoiceData()
        
        invoice.address = invoiceDictionary.objectForKey(QRKeys.Address.rawValue) as! String
        invoice.name = invoiceDictionary.objectForKey(QRKeys.Name.rawValue) as! String
        invoice.amount = invoiceDictionary.objectForKey(QRKeys.Amount.rawValue) as! Double / 1000000
        invoice.message = invoiceDictionary.objectForKey(QRKeys.Message.rawValue) as! String
        
        State.invoice = invoice
        
        if State.invoice != nil {
            let navDelegate = (self.delegate as? QRViewController)?.delegate as? MainVCDelegate
            if navDelegate != nil  {
                navDelegate!.pageSelected(SegueToSendTransaction)
            }
        }

    }
    
    final func addFriend(friendDictionary :NSDictionary) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddCustomContactVC =  storyboard.instantiateViewControllerWithIdentifier("AddCustomContact") as! AddCustomContactVC
        contactCustomVC.view.frame = CGRect(x: 0, y: 0, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height)
        contactCustomVC.view.layer.opacity = 0
        contactCustomVC.delegate = self
        
        contactCustomVC.firstName.text = friendDictionary.objectForKey(QRKeys.Name.rawValue) as? String
        contactCustomVC.lastName.text = friendDictionary.objectForKey("surname") as? String
        contactCustomVC.address.text = friendDictionary.objectForKey(QRKeys.Address.rawValue) as? String
        _tempController = contactCustomVC
        
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)

    }
  
    // MARK: -  AddCustomContactDelegate

    func contactAdded(successfuly: Bool, sendTransaction :Bool) {
        if successfuly {
            let navDelegate = (self.delegate as? QRViewController)?.delegate as? MainVCDelegate
            if navDelegate != nil  {
                if sendTransaction {
                    let correspondent :Correspondent = Correspondent()
                    
                    for email in AddressBook.newContact!.emailAddresses{
                        if email.label == "NEM" {
                            correspondent.address = (email.value as? String) ?? " "
                            correspondent.name = correspondent.address.nemName()
                        }
                    }
                    State.currentContact = correspondent
                }
                navDelegate!.pageSelected(sendTransaction ? SegueToSendTransaction : SegueToAddressBook)
            }
        }
    }
    
    func popUpClosed(successfuly :Bool) {
        qrScaner.play()
    }
    
    func contactChanged(successfuly: Bool, sendTransaction :Bool) {

    }
}
