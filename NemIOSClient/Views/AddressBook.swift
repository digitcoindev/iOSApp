import UIKit
import AddressBook

class AddressBook: AbstractViewController , UITableViewDelegate , UIAlertViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filter: FilterButton!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchTextField: NEMTextField!
    
    let dataManager :CoreDataManager = CoreDataManager()
    let addressBook : ABAddressBookRef? = AddressBookManager.addressBook
    var contacts :NSArray? = AddressBookManager.contacts
    var displayList :NSMutableArray = NSMutableArray()
    var walletData :AccountGetMetaData!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if State.fromVC != SegueToAddressBook
        {
            State.fromVC = SegueToAddressBook
        }
        
        State.currentVC = SegueToAddressBook
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Contacts")
        
        if State.currentServer != nil
        {
            var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
            var publicKey = KeyGenerator().generatePublicKey(privateKey)
            var account_address = AddressGenerator().generateAddress(publicKey)
            
            APIManager().accountGet(State.currentServer!, account_address: account_address)
        }
        
        self.filterChanged(self)
        
        searchContainer.layer.cornerRadius = 5
        filter.layer.cornerRadius = 5
        tableView.layer.cornerRadius = 5
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    final func accountGetSuccessed(notification: NSNotification)
    {
        walletData = (notification.object as! AccountGetMetaData)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func endAction(sender: AnyObject)
    {
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func filterChanged(sender: AnyObject)
    {
        displayList.removeAllObjects()
        
        if contacts == nil || contacts!.count == 0
        {
            return
        }
        
        for contact in contacts!
        {
            var isValidValue = false
            var needToAddSearchFilter = self.searchTextField.text != nil && self.searchTextField.text != ""
            
            if needToAddSearchFilter
            {
                if ABRecordCopyValue(contact, kABPersonFirstNameProperty) != nil
                {
                    if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text).evaluateWithObject(ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeUnretainedValue() as! String)
                    {
                        isValidValue = true
                    }
                }
                
                if ABRecordCopyValue(contact, kABPersonLastNameProperty) != nil
                {
                    if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text).evaluateWithObject(ABRecordCopyValue(contact, kABPersonLastNameProperty).takeUnretainedValue() as! String)
                    {
                        isValidValue = true
                    }
                }
            }
            else
            {
                isValidValue = true
            }
            
            if !isValidValue
            {
                continue
            }
            

            let emails: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonEmailProperty).takeUnretainedValue()  as ABMultiValueRef
            let count  :Int = ABMultiValueGetCount(emails)
            
            if count > 0
            {
                var isConnectedNEMAddress = false
                
                for var index:CFIndex = 0; index < count; ++index
                {
                    var lable  = ABMultiValueCopyLabelAtIndex(emails, index)
                    if lable != nil
                    {
                        if lable.takeUnretainedValue()  == "NEM"
                        {
                            isConnectedNEMAddress = true
                        }
                    }
                }
                
                if self.filter.isFilterActive != isConnectedNEMAddress
                {
                    continue
                }
            }
            else if self.filter.isFilterActive
            {
                continue
            }
            
            displayList.addObject(contact)
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func addContact(sender: AnyObject)
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
                            textField.placeholder = "address"
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
                            
                            AddressBookManager.refresh()
                            self.contacts = AddressBookManager.contacts
                            self.filterChanged(self)
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
                    println("No access.")
                    
                }
        })
        
        self.contacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
        self.tableView.reloadData()
    }
    
    final func sortContacts()
    {
        
    }
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return displayList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : AddressCell = self.tableView.dequeueReusableCellWithIdentifier("address cell") as! AddressCell
        var person :ABRecordRef = displayList[indexPath.row]
        
        cell.user.text = ""
        
        if ABRecordCopyValue(person, kABPersonFirstNameProperty) != nil
        {
            cell.user.text = (ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as! String) + " "
        }
        
        if  ABRecordCopyValue(person, kABPersonLastNameProperty) != nil
        {
            cell.user.text = cell.user.text! + ((ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)! as String)
        }
        
        let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeUnretainedValue()  as ABMultiValueRef
        let count  :Int = ABMultiValueGetCount(emails)
        
        if count > 0
        {
            for var index:CFIndex = 0; index < count; ++index
            {
                var lable  = ABMultiValueCopyLabelAtIndex(emails, index)
                if lable != nil
                {
                    if lable.takeUnretainedValue()  == "NEM"
                    {
                        cell.indicator.hidden = false
                    }
                    else
                    {
                        cell.indicator.hidden = true
                    }
                }
            }
        }
        else
        {
            cell.indicator.hidden = true
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var cell :AddressCell = tableView.cellForRowAtIndexPath(indexPath) as! AddressCell
        
        if cell.indicator.hidden
        {
            var alert1 :UIAlertController = UIAlertController(title: "Add NEM address", message: "Input new address", preferredStyle: UIAlertControllerStyle.Alert)
            
            var address :UITextField!
            alert1.addTextFieldWithConfigurationHandler
                {
                    textField -> Void in
                    textField.placeholder = "address"
                    textField.keyboardType = UIKeyboardType.ASCIICapable
                    textField.returnKeyType = UIReturnKeyType.Done
                    
                    address = textField
                    
            }
            
            var addNEMaddress :UIAlertAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default)
                {
                    alertAction -> Void in
                    
                    if(address != "")
                    {
                        var emailMultiValue :ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABPersonEmailProperty)).takeRetainedValue()
                        var error: Unmanaged<CFErrorRef>? = nil
                        
                        ABMultiValueAddValueAndLabel(emailMultiValue, address.text, "NEM", nil)
                        ABRecordSetValue(self.displayList[indexPath.row], kABPersonEmailProperty, emailMultiValue, &error)
                        ABAddressBookSave(self.addressBook, &error)
                        
                        self.contacts = AddressBookManager.contacts
                        self.filterChanged(self)
                    }

            }
            
            var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                {
                    alertAction -> Void in
                    alert1.dismissViewControllerAnimated(true, completion: nil)
                    cell.setSelected(false, animated: true)
            }
            
            alert1.addAction(addNEMaddress)
            alert1.addAction(cancel)
            
            self.presentViewController(alert1, animated: true, completion: nil)

        }
        else if walletData != nil
        {
            if walletData.publicKey != nil
            {
                var person :ABRecordRef = displayList[indexPath.row]
                
                let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
                let count  :Int = ABMultiValueGetCount(emails)
                
                var key :String!

                for var index = 0; index < count; ++index
                {
                    var lable : String = ABMultiValueCopyLabelAtIndex(emails, index).takeRetainedValue() as String
                    if lable == "NEM"
                    {
                        key = ABMultiValueCopyValueAtIndex(emails, index).takeUnretainedValue() as! String
                        break
                    }
                }
                var title :String = ""
                
                if var name = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString
                {
                    title = (name as String)
                }
                
                if ABRecordCopyValue(person, kABPersonLastNameProperty) != nil
                {
                    title = title + " " +  ((ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as! NSString) as String)
                }
                
                State.currentContact = nil
                
                State.toVC = SegueToPasswordValidation
                
                var correspondents : NSArray = dataManager.getCorrespondents()
                
                for correspondent  in correspondents
                {
                   if (correspondent as! Correspondent).public_key == key
                   {
                        State.currentContact = correspondent as? Correspondent
                        break
                    }
                }
                if State.currentContact == nil
                {
                    State.currentContact = dataManager.addCorrespondent(key, name: title , address : key ,owner: State.currentWallet!)
                }

                NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToMessages )
            }
            else
            {
                var alert :UIAlertView = UIAlertView(title: "Info", message: "Your account could not sent transactions. Please increase your balance", delegate: self, cancelButtonTitle: "OK")
                alert.show()

            }
        }
    }
}

