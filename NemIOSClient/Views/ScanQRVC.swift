import UIKit
import AddressBook
import AddressBookUI

class ScanQRVC: AbstractViewController, QRDelegate, AddCustomContactDelegate
{
    @IBOutlet weak var qrScaner: QR!
    
    private var _tempController: AbstractViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToScanQR
        State.currentVC = SegueToScanQR
        qrScaner.delegate = self
    }
    override func viewDidAppear(animated: Bool) {
        qrScaner.scanQR(qrScaner.frame.width , height: qrScaner.frame.height )
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
            
            
            switch (jsonStructure!.objectForKey("type") as! Int) {
            case QRType.UserData.rawValue:
                
                let friendDictionary :NSDictionary = jsonStructure!.objectForKey("data") as! NSDictionary
                
                if (AddressBookManager.isAllowed ?? false) {
                    addFriend(friendDictionary)
                }
                else {
                    let alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("CONTACTS_IS_UNAVAILABLE", comment: "Description"), preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            case QRType.Invoice.rawValue:
                
                let invoiceDictionary :NSDictionary = jsonStructure!.objectForKey("data") as! NSDictionary
                
                performInvoice(invoiceDictionary)
                
            default :
                qrScaner.play()
                break
            }
        }
    }
    
    func failedWithError(text: String) {       
        let alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    final func detectedQR(notification: NSNotification) {
            }
    
    final func performInvoice(invoiceDictionary :NSDictionary) {
        var invoice :InvoiceData = InvoiceData()
        
        invoice.address = invoiceDictionary.objectForKey("address") as! String
        invoice.name = invoiceDictionary.objectForKey("name") as! String
        invoice.amount = invoiceDictionary.objectForKey("amount") as! Double
        invoice.message = invoiceDictionary.objectForKey("message") as! String
        
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
        
        contactCustomVC.firstName.text = friendDictionary.objectForKey("name") as? String
        contactCustomVC.lastName.text = friendDictionary.objectForKey("surname") as? String
        contactCustomVC.address.text = friendDictionary.objectForKey("address") as? String
        _tempController = contactCustomVC
        
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)

    }
  
    // MARK: -  AddCustomContactDelegate

    func contactAdded(successfuly: Bool) {
        if successfuly {
            let navDelegate = (self.delegate as? QRViewController)?.delegate as? MainVCDelegate
            if navDelegate != nil  {
                navDelegate!.pageSelected(SegueToAddressBook)
            }
        }
    }
    func popUpClosed(successfuly :Bool) {
        qrScaner.play()
    }
    
    func contactChanged(successfuly: Bool) {

    }
}
