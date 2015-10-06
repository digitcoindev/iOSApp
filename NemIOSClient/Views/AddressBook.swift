import UIKit
import AddressBook

class AddressBook: AbstractViewController, UITableViewDelegate, UIAlertViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, AddCustomContactDelegate
{
    // MARK: - @IBOutlet

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filter: FilterButton!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchTextField: NEMTextField!
    
    // MARK: - Private Variables

    private let _apiManager :APIManager = APIManager()
    private var _tempController: AbstractViewController? = nil
    private var _walletData :AccountGetMetaData!
    private var _isEditing = false

    // MARK: - Properties

    var contacts :NSArray? = AddressBookManager.contacts
    var displayList :NSMutableArray = NSMutableArray()
    
    // MARK: - Load Metods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToLoginVC
        State.currentVC = SegueToLoginVC
        
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let publicKey = KeyGenerator.generatePublicKey(privateKey)
        let account_address = AddressGenerator.generateAddress(publicKey)
        
        if State.currentServer != nil {
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
        
        self.filterChanged(self)
        
        searchContainer.layer.cornerRadius = 5
        filter.layer.cornerRadius = 5
        tableView.layer.cornerRadius = 5
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset.right = 15
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBAction

    @IBAction func endAction(sender: AnyObject) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
        
        for cell in self.tableView.visibleCells {
            (cell as! AddressCell).isEditable = _isEditing
        }
        
        _isEditing = !_isEditing
    }
    
    @IBAction func filterChanged(sender: AnyObject) {
        displayList.removeAllObjects()
        
        AddressBookManager.refresh({ () -> Void in
            self.contacts = AddressBookManager.contacts
        })
        
        if contacts == nil || contacts!.count == 0 {
            return
        }
        
        for contact in contacts! {
            var isValidValue = false
            let needToAddSearchFilter = self.searchTextField.text != nil && self.searchTextField.text != ""
            
            if needToAddSearchFilter {
                if ABRecordCopyValue(contact, kABPersonFirstNameProperty) != nil {
                    if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeUnretainedValue() as! String)
                    {
                        isValidValue = true
                    }
                }
                
                if ABRecordCopyValue(contact, kABPersonLastNameProperty) != nil {
                    if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(ABRecordCopyValue(contact, kABPersonLastNameProperty).takeUnretainedValue() as! String)
                    {
                        isValidValue = true
                    }
                }
            }
            else {
                isValidValue = true
            }
            
            if !isValidValue {
                continue
            }
            
            let emails: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonEmailProperty).takeUnretainedValue()  as ABMultiValueRef
            let count  :Int = ABMultiValueGetCount(emails)
            
            if count > 0 {
                var isConnectedNEMAddress = false
                
                for var index:CFIndex = 0; index < count; ++index {
                    let lable  = ABMultiValueCopyLabelAtIndex(emails, index)
                    if lable != nil
                    {
                        if lable.takeUnretainedValue()  == "NEM"
                        {
                            isConnectedNEMAddress = true
                        }
                    }
                }
                
                if self.filter.isFilterActive != isConnectedNEMAddress {
                    continue
                }
            }
            else if self.filter.isFilterActive {
                continue
            }
            
            displayList.addObject(contact)
        }
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addNewContact(sender: AnyObject) {
        _addContact()
    }
    
    // MARK: - Table View Data Sourse
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayList.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : AddressCell = self.tableView.dequeueReusableCellWithIdentifier("address cell") as! AddressCell
        cell.editDelegate = self
        let person :ABRecordRef = displayList[indexPath.row]
        cell.isEditable = !_isEditing
        cell.infoLabel.text = ""
        
        if ABRecordCopyValue(person, kABPersonFirstNameProperty) != nil {
            cell.infoLabel.text = (ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as! String) + " "
        }
        
        if  ABRecordCopyValue(person, kABPersonLastNameProperty) != nil {
            cell.infoLabel.text = cell.infoLabel.text! + ((ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)! as String)
        }
        
        let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeUnretainedValue()  as ABMultiValueRef
        let count  :Int = ABMultiValueGetCount(emails)
        
        if count > 0 {
            for var index:CFIndex = count - 1; index >= 0; --index {
                let lable  = ABMultiValueCopyLabelAtIndex(emails, index)
                if lable != nil {
                    if lable.takeUnretainedValue()  == "NEM" {
                        cell.isAddress = true
                        break
                    } else {
                        cell.isAddress = false
                    }
                }
            }
        }
        else {
            cell.isAddress = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell :AddressCell = tableView.cellForRowAtIndexPath(indexPath) as! AddressCell
        
        if _isEditing || !cell.isAddress {
            _changeContact(displayList[indexPath.row])
        } else if _walletData != nil {
            _sendMessageTo(displayList[indexPath.row])
        }
        
//        else if _walletData != nil {
//            if _walletData.publicKey != nil {
//                let person :ABRecordRef = displayList[indexPath.row]
//                
//                let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
//                let count  :Int = ABMultiValueGetCount(emails)
//                
//                var key :String!
//                
//                for var index = 0; index < count; ++index {
//                    let lable : String = ABMultiValueCopyLabelAtIndex(emails, index).takeRetainedValue() as String
//                    if lable == "NEM"
//                    {
//                        key = ABMultiValueCopyValueAtIndex(emails, index).takeUnretainedValue() as! String
//                        break
//                    }
//                }
//                var title :String = ""
//                
//                if let name = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString {
//                    title = (name as String)
//                }
//                
//                if ABRecordCopyValue(person, kABPersonLastNameProperty) != nil {
//                    title = title + " " +  ((ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as! NSString) as String)
//                }
//                
//                State.currentContact = nil
//                
//                State.toVC = SegueToPasswordValidation
//                
//                if Validate.address(key) {
//                    let correspondent :Correspondent = Correspondent()
//                    correspondent.address = key
//                    correspondent.name = title
//                    State.currentContact = correspondent
//                    
//                }
//                
//                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
//                    (self.delegate as! MainVCDelegate).pageSelected(SegueToPasswordValidation)
//                }
//            }
//            else {
//                let alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: "Your account could not sent transactions. Please increase your balance", delegate: self, cancelButtonTitle: "OK")
//                alert.show()
//                
//            }
//        }
    }
    
    // MARK: -  Private Helpers

    final private func _sendMessageTo(contact: ABRecordRef)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :MessageToContactVC =  storyboard.instantiateViewControllerWithIdentifier("SendMessageToContact") as! MessageToContactVC
        contactCustomVC.view.frame = CGRect(x: 0, y: topView.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - topView.frame.height)
        contactCustomVC.view.layer.opacity = 0
        contactCustomVC.delegate = self
        _tempController = contactCustomVC

        AddressBookManager.getUserInfoFor(contact, responce: { (info) -> Void in
            contactCustomVC.userInfoLabel.text = info
            
            AddressBookManager.getNemAddressFor(contact, responce: { (address) -> Void in
                if address.count > 0 {
                    contactCustomVC.userAddressLabel.text = address.last!
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.view.addSubview(contactCustomVC.view)
                        
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            contactCustomVC.view.layer.opacity = 1
                            }, completion: nil)
                    })
                }
            })
            
        })
    }
    
    final private func _addContact()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddCustomContactVC =  storyboard.instantiateViewControllerWithIdentifier("AddCustomContact") as! AddCustomContactVC
        contactCustomVC.view.frame = CGRect(x: 0, y: topView.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - topView.frame.height)
        contactCustomVC.view.layer.opacity = 0
        contactCustomVC.delegate = self
        
        _tempController = contactCustomVC
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    final private func _changeContact(contact: ABRecordRef)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddCustomContactVC =  storyboard.instantiateViewControllerWithIdentifier("AddCustomContact") as! AddCustomContactVC
        contactCustomVC.view.frame = CGRect(x: 0, y: topView.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - topView.frame.height)
        contactCustomVC.view.layer.opacity = 0
        contactCustomVC.saveBtn.setTitle(NSLocalizedString("CHANGE_CONTACT", comment: "Title"), forState: .Normal)
        contactCustomVC.contact = contact
        contactCustomVC.delegate = self
        
        _tempController = contactCustomVC
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    // MARK: -  AddCustomContactDelegate
    
    func contactAdded(successfuly: Bool) {
        if successfuly {
            AddressBookManager.refresh({ () -> Void in
                self.contacts = AddressBookManager.contacts
                self.filterChanged(self)
            })
        }
    }
    
    func contactChanged(successfuly: Bool) {
        if successfuly {
            AddressBookManager.refresh({ () -> Void in
                self.contacts = AddressBookManager.contacts
                self.filterChanged(self)
            })
        }
    }
    
    // MARK: - EditableTableViewCellDelegate Methods
    
    final func deleteCell(cell: EditableTableViewCell) {
        let index :NSIndexPath = tableView.indexPathForCell(cell)!
        
        if index.row < displayList.count {
            AddressBookManager.deleteContact(displayList[index.row], responce: nil)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayList.removeObjectAtIndex(index.row)
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)

            })
        }
    }
    
    // MARK: - APIManagerDelegate Methods
    
    final func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        _walletData = account
    }
}

