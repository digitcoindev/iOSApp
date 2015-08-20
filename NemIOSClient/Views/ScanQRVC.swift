import UIKit
import AddressBook
import AddressBookUI

class ScanQRVC: AbstractViewController
{
    @IBOutlet weak var qrScaner: QR!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if State.fromVC != SegueToScanQR {
            State.fromVC = SegueToScanQR
        }
        
        State.currentVC = SegueToScanQR
        
        observer.addObserver(self, selector: "detectedQR:", name: "Scan QR", object: nil)
        
        qrScaner.scanQR(qrScaner.frame.width , height: qrScaner.frame.height )
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Scan your friend")

    }

    
    final func detectedQR(notification: NSNotification) {
        var base64String :String = notification.object as! String
        if base64String != "Empty scan" {
            var jsonData :NSData = NSData(base64EncodedString: base64String)
            var err: NSError?
            var jsonStructure :NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves, error: &err) as! NSDictionary
            
            switch (jsonStructure.objectForKey("type") as! Int) {
            case 1:
                
                var friendDictionary :NSDictionary = jsonStructure.objectForKey("data") as! NSDictionary
                
                if AddressBookManager.isAllowed {
                    addFriend(friendDictionary)
                }
                else {
                    var alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: "Contacts is unavailable.\nTo allow contacts follow to this directory\nSettings -> Privacy -> Contacts.", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
                
            case 3:
                
                var invoiceDictionary :NSDictionary = jsonStructure.objectForKey("data") as! NSDictionary
                
                performInvoice(invoiceDictionary)
                
            default :
                qrScaner.play()
                break
            }
        }
    }
    
    final func performInvoice(invoiceDictionary :NSDictionary) {
        var invoice :InvoiceData = InvoiceData()
        
        invoice.address = invoiceDictionary.objectForKey("address") as! String
        invoice.name = invoiceDictionary.objectForKey("name") as! String
        invoice.amount = invoiceDictionary.objectForKey("amount") as! Int
        invoice.message = invoiceDictionary.objectForKey("message") as! String
        
        State.invoice = invoice
        
        if State.invoice != nil {
            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToSendTransaction )
        }

    }
    
    final func addFriend(friendDictionary :NSDictionary) {
        ABAddressBookRequestAccessWithCompletion(addressBook, {
                (granted : Bool, error: CFError!) -> Void in
                if granted == true {
                    var newContact  :ABRecordRef! = ABPersonCreate().takeRetainedValue()
                    
                    var error: Unmanaged<CFErrorRef>? = nil
                    var emailMultiValue :ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABPersonEmailProperty)).takeRetainedValue()
                    
                    var alert1 :UIAlertController = UIAlertController(title: "Add NEM contact", message: "Input your data", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    var firstName :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.text = friendDictionary.objectForKey("name") as! String
                            textField.placeholder = "firstName"
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            firstName = textField
                            
                    }
                    
                    var lastName :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.text = friendDictionary.objectForKey("surname") as! String
                            textField.placeholder = "lastName"
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            lastName = textField
                            
                    }
                    
                    var address :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.text = friendDictionary.objectForKey("address") as! String
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            address = textField
                            
                    }
                    
                    var addNEMaddress :UIAlertAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default)
                        {
                            alertAction -> Void in
                            
                            ABRecordSetValue(newContact, kABPersonFirstNameProperty, firstName.text, &error)
                            ABRecordSetValue(newContact, kABPersonLastNameProperty, lastName.text, &error)
                            ABMultiValueAddValueAndLabel(emailMultiValue, address.text, "NEM", nil)
                            ABRecordSetValue(newContact, kABPersonEmailProperty, emailMultiValue, &error)
                            ABAddressBookAddRecord(self.addressBook, newContact, &error)
                            ABAddressBookSave(self.addressBook, &error)
                            
                            State.toVC = SegueToMessages
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToAddressBook )
                            
                    }
                    
                    
                    var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                        {
                            alertAction -> Void in
                            alert1.dismissViewControllerAnimated(true, completion: nil)
                            self.qrScaner.play()
                    }
                    
                    alert1.addAction(addNEMaddress)
                    alert1.addAction(cancel)
                    
                    self.presentViewController(alert1, animated: true, completion: nil)
                    
                }
                else {
                    var alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: "Can not access adressbook.", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
