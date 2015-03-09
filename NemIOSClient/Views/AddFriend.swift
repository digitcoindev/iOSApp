import UIKit
import AddressBook

class AddFriend: UIViewController
{
    @IBOutlet weak var qrScaner: QR!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToAddFriend
        {
            State.fromVC = SegueToAddFriend
        }
        
        State.currentVC = SegueToAddFriend
        
        observer.addObserver(self, selector: "detectedQR:", name: "Scan QR", object: nil)
        
        qrScaner.scanQR(qrScaner.frame.width , height: qrScaner.frame.height )
    }

    final func detectedQR(notification: NSNotification)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook,
            {
                (granted : Bool, error: CFError!) -> Void in
                if granted == true
                {
                    var newContact  :ABRecordRef! = ABPersonCreate().takeRetainedValue()
                    
                    var error: Unmanaged<CFErrorRef>? = nil
                    var emailMultiValue :ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABPersonEmailProperty)).takeRetainedValue()
                    
                    var alert1 :UIAlertController = UIAlertController(title: "Add NEM account", message: "Input your data", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    var firstName :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.placeholder = "firstName"
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            firstName = textField
                            
                    }
                    
                    var lastName :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.placeholder = "lastName"
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            lastName = textField
                            
                    }
                    
                    var address :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.text = notification.object as String
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
                    }
                    
                    alert1.addAction(addNEMaddress)
                    alert1.addAction(cancel)
                    
                    self.presentViewController(alert1, animated: true, completion: nil)
                    
                }
                else
                {
                    var alert :UIAlertView = UIAlertView(title: "Info", message: "Can not access adressbook.", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
        })

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
