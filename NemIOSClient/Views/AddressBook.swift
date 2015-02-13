import UIKit
import AddressBook

class AddressBook: UIViewController , UITableViewDelegate , UIAlertViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    let dataManager :CoreDataManager = CoreDataManager()
    let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    var contacts :NSArray = NSArray()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if State.fromVC != SegueToAddressBook
        {
            State.fromVC = SegueToAddressBook
        }
        
        State.currentVC = SegueToAddressBook

        ABAddressBookRequestAccessWithCompletion(addressBook,
            {
                (granted : Bool, error: CFError!) -> Void in
                if granted == true
                {
                    self.contacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
                    self.tableView.reloadData()
                }
                else
                {
                    println("no access")
                    
                }
        })

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()


    }

    @IBAction func addContact(sender: AnyObject)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook,
            {
                (granted : Bool, error: CFError!) -> Void in
                if granted == true
                {
                    var newContact  :ABRecordRef! = ABPersonCreate().takeRetainedValue()
                    var success:Bool = false
                    var newFirstName:NSString = "\(rand()%20)"
                    var newLastName = ""
                    var address = "Dfd5ssGHS5231fsdseg54d"
                    
                    var error: Unmanaged<CFErrorRef>? = nil
                    var emailMultiValue :ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABPersonEmailProperty)).takeRetainedValue()
                    
                    success = ABRecordSetValue(newContact, kABPersonFirstNameProperty, newFirstName, &error)
                    println("setting first name was successful? \(success)")
                    
                    success = ABRecordSetValue(newContact, kABPersonLastNameProperty, newLastName, &error)
                    println("setting last name was successful? \(success)")
                    
                    success = ABMultiValueAddValueAndLabel(emailMultiValue, address, "NEM", nil)
                    println("creating nem address was successful? \(success)")
                    
                    success = ABRecordSetValue(newContact, kABPersonEmailProperty, emailMultiValue, &error)
                    println("setting nem address was successful? \(success)")
                    
                    success = ABAddressBookAddRecord(self.addressBook, newContact, &error)
                    println("addressBook addRecord successful? \(success)")
                    
                    success = ABAddressBookSave(self.addressBook, &error)
                    println("addressBook Save successful? \(success)")
                }
                else
                {
                    println("no access")
                    
                }
        })
        
        self.contacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : AddressCell = self.tableView.dequeueReusableCellWithIdentifier("address cell") as AddressCell
        var person :ABRecordRef = contacts[indexPath.row]
        
        cell.user.text = ""
        
        if var name = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString
        {
            cell.user.text = name + " "
        }
        
        if var surname = ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString
        {
            cell.user.text = cell.user.text! +  (ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)!
        }
        
        let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()  as ABMultiValueRef
        let count  :Int = ABMultiValueGetCount(emails)
        if count > 0
        {
            for var index = 0; index < count; ++index
            {
                var lable : String = ABMultiValueCopyLabelAtIndex(emails, index).takeRetainedValue() as NSString
                if lable  == "NEM"
                {
                    cell.indicator.hidden = false
                }
            }
        }
        else
        {
            println("No email address")
        }

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var cell :AddressCell = tableView.cellForRowAtIndexPath(indexPath) as AddressCell
        
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
                        var success :Bool!
                        
                        success = ABMultiValueAddValueAndLabel(emailMultiValue, address.text, "NEM", nil)
                        println("creating nem address was successful? \(success)")
                        
                        success = ABRecordSetValue(self.contacts[indexPath.row], kABPersonEmailProperty, emailMultiValue, &error)
                        println("setting nem address was successful? \(success)")
                        
                        success = ABAddressBookSave(self.addressBook, &error)
                        println("addressBook Save successful? \(success)")
                        
                        self.tableView.reloadData()
                    }

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
            var person :ABRecordRef = contacts[indexPath.row]
            
            let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
            let count  :Int = ABMultiValueGetCount(emails)
            
            var key :String!

            for var index = 0; index < count; ++index
            {
                var lable : String = ABMultiValueCopyLabelAtIndex(emails, index).takeRetainedValue()
                if lable == "NEM"
                {
                    key = ABMultiValueCopyValueAtIndex(emails, index).takeUnretainedValue() as String
                    println(key)
                    break
                }
            }
            var name :String = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString as String
            name = name + " " +  (ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)!
            
            State.currentContact = dataManager.addCorrespondent(key, name: name)
            
            State.fromVC = SegueToAddressBook
            
            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:State.toVC )

        }
}
    
}

