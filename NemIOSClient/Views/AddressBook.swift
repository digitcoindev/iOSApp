import UIKit
import Contacts

class AddressBook: AbstractViewController, UITableViewDelegate, UIAlertViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, AddCustomContactDelegate
{
    // MARK: - @IBOutlet

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchTextField: NEMTextField!
    
    // MARK: - Static Variables

    static var newContact :CNContact? = nil
    
    // MARK: - Private Variables

    private let _apiManager :APIManager = APIManager()
    private var _tempController: AbstractViewController? = nil
    private var _walletData :AccountGetMetaData!
    private var _isEditing = false
    private var _newContact :CNContact? = nil
    
    // MARK: - Properties

    var contacts :NSArray? = AddressBookManager.contacts
    var displayList :[CNContact] = []
    
    // MARK: - Load Metods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToLoginVC
        State.currentVC = SegueToLoginVC
        
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.currentWallet!.password)
        let publicKey = KeyGenerator.generatePublicKey(privateKey!)
        let account_address = AddressGenerator.generateAddress(publicKey)
        
        if State.currentServer != nil {
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
        
        _newContact = AddressBook.newContact
        AddressBook.newContact = nil
        
        searchContainer.layer.cornerRadius = 5
        tableView.layer.cornerRadius = 5
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset.right = 15
        filterChanged(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBAction

    @IBAction func endAction(sender: AnyObject) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
        _isEditing = !_isEditing

        for cell in self.tableView.visibleCells {
            (cell as! AddressCell).isEditable = _isEditing
        }
    }
    
    func filterChanged(sender: AnyObject) {
        displayList.removeAll()
        
        AddressBookManager.refresh({ () -> Void in
            self.contacts = AddressBookManager.contacts
            
            if self.contacts == nil || self.contacts!.count == 0 {
                return
            }
            
            for contact in self.contacts! {
                var isValidValue = false
                let needToAddSearchFilter = self.searchTextField.text != nil && self.searchTextField.text != ""
                
                if needToAddSearchFilter {
                    if let name = contact.givenName {
                        if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(name)
                        {
                            isValidValue = true
                        }
                    }
                    
                    if let surname = contact.familyName {
                        if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(surname)
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
                
                self.displayList.append(contact as! CNContact)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func addNewContact(sender: AnyObject) {
        _addContact()
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
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
        let person :CNContact = displayList[indexPath.row]
        cell.isEditable = _isEditing
        cell.infoLabel.text = ""
        
        if ((_newContact?.givenName == person.givenName) && (_newContact?.familyName == person.familyName)) ?? false {
            _newContact = nil
            
            cell.selectContact()
        }
        
        cell.infoLabel.text = person.givenName + " " + person.familyName
        
        let emails: [CNLabeledValue] = person.emailAddresses
        
        var _isAddress = false
        
        for email in emails {
            if email.label == "NEM" {
                _isAddress = true
                break
            }
        }
        
        cell.isAddress = _isAddress
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell :AddressCell = tableView.cellForRowAtIndexPath(indexPath) as! AddressCell
        
        if _isEditing || !cell.isAddress {
            _changeContact(displayList[indexPath.row])
        } else if _walletData != nil {
            _sendMessageTo(displayList[indexPath.row])
        }
    }
    
    // MARK: -  Private Helpers

    final private func _sendMessageTo(contact: CNContact)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :MessageToContactVC =  storyboard.instantiateViewControllerWithIdentifier("SendMessageToContact") as! MessageToContactVC
        contactCustomVC.view.frame = CGRect(x: 0, y: topView.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - topView.frame.height)
        contactCustomVC.view.layer.opacity = 0
        contactCustomVC.delegate = self
        _tempController = contactCustomVC
        
        contactCustomVC.userInfoLabel.text = contact.givenName + " " + contact.familyName
        
        for email in contact.emailAddresses{
            if email.label == "NEM" {
                contactCustomVC.userAddressLabel.text = email.value as? String ?? " "
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(contactCustomVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                contactCustomVC.view.layer.opacity = 1
                }, completion: nil)
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
    
    final private func _changeContact(contact: CNContact)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddCustomContactVC =  storyboard.instantiateViewControllerWithIdentifier("AddCustomContact") as! AddCustomContactVC
        contactCustomVC.view.frame = CGRect(x: 0, y: topView.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - topView.frame.height)
        contactCustomVC.view.layer.opacity = 0
        contactCustomVC.firstName.text = contact.givenName
        contactCustomVC.lastName.text = contact.familyName
        
        for email in contact.emailAddresses{
            if email.label == "NEM" {
                contactCustomVC.address.text = email.value as? String ?? ""
            }
        }
        
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
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for cell in self.tableView.visibleCells {
                    (cell as! AddressCell).isEditable = false
                }
            })
            _isEditing = false
            _newContact = AddressBook.newContact
            AddressBook.newContact = nil
            
            self.filterChanged(self)
        }
    }
    
    func contactChanged(successfuly: Bool) {
        if successfuly {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for cell in self.tableView.visibleCells {
                    (cell as! AddressCell).isEditable = false
                }
            })
            _isEditing = false
            _newContact = AddressBook.newContact
            AddressBook.newContact = nil

            self.filterChanged(self)
        }
    }
    
    func popUpClosed(successfuly :Bool)
    {
        
    }
    
    // MARK: - EditableTableViewCellDelegate Methods
    
    final func deleteCell(cell: EditableTableViewCell) {
        let index :NSIndexPath = tableView.indexPathForCell(cell)!
        
        if index.row < displayList.count {
            AddressBookManager.deleteContact(displayList[index.row], responce: nil)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayList.removeAtIndex(index.row)
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)

            })
        }
    }
    
    // MARK: - APIManagerDelegate Methods
    
    final func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        _walletData = account
    }
}

