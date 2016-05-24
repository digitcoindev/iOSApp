import UIKit
import Contacts

class AddressBook: AbstractViewController, UITableViewDelegate, UIAlertViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, AddCustomContactDelegate
{
    // MARK: - @IBOutlet

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchTextField: NEMTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Static Variables

    static var newContact :CNContact? = nil
    
    // MARK: - Private Variables

    private let _apiManager :APIManager = APIManager()
    private var _tempController: AbstractViewController? = nil
    private var _walletData :AccountGetMetaData!
    private var _isEditing = false
    private var _newContact :CNContact? = nil
    
    // MARK: - Properties

    var contacts :[CNContact]? = AddressBookManager.contacts
    var displayList :[CNContact] = []
    
    // MARK: - Load Metods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToAddressBook
        
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let publicKey = KeyGenerator.generatePublicKey(privateKey!)
        let account_address = AddressGenerator.generateAddress(publicKey)
        
        if State.currentServer != nil {
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
        
        _newContact = AddressBook.newContact
        AddressBook.newContact = nil
        
        titleLabel.text = "ADDRESS_BOOK".localized()
        editButton.setTitle("EDIT".localized(), forState: UIControlState.Normal)
        addButton.setTitle("  " + "ADD_CONTACT".localized(), forState: UIControlState.Normal)
        searchTextField.placeholder = "SEARCH_CONTACTS".localized()
        searchContainer.layer.cornerRadius = 5
        tableView.layer.cornerRadius = 5
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset.right = 15
        filterChanged(self)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        State.currentVC = SegueToAddressBook

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBAction

    @IBAction func endAction(sender: AnyObject) {
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
        if _tempController != nil { return }

        _isEditing = !_isEditing
        
        let title = _isEditing ? "DONE".localized() : "EDIT".localized()
        editButton.setTitle(title, forState: .Normal)

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
                    //TODO: Fixed to Swift 2.2 in Version 2 Build 31 BETA, could be error
                    
                        if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(contact.givenName)
                        {
                            isValidValue = true
                        }
                    
                        if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(contact.familyName)
                        {
                            isValidValue = true
                        }
                }
                else {
                    isValidValue = true
                }
                
                if !isValidValue {
                    continue
                }
                
                self.displayList.append(contact)
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
        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMessages)
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
                contactCustomVC.userAddressLabel.text = (email.value as? String)?.nemAddressNormalised() ?? " "
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
        
        contactCustomVC.saveBtn.setTitle("CHANGE_CONTACT".localized(), forState: .Normal)
        contactCustomVC.contact = contact
        contactCustomVC.delegate = self
        
        _tempController = contactCustomVC
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    // MARK: -  AddCustomContactDelegate
    
    func contactAdded(successfuly: Bool, sendTransaction :Bool) {
        if successfuly {
            _tempController = nil
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for cell in self.tableView.visibleCells {
                    (cell as! AddressCell).isEditable = false
                }
            })
            
            _isEditing = false
            _newContact = AddressBook.newContact
            AddressBook.newContact = nil
            
            self.filterChanged(self)
            
            if sendTransaction {
                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                    
                    let correspondent :Correspondent = Correspondent()
                    
                    for email in _newContact!.emailAddresses{
                        if email.label == "NEM" {
                            correspondent.address = (email.value as? String) ?? " "
                            correspondent.name = correspondent.address.nemName()
                        }
                    }
                    State.currentContact = correspondent
                    
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToSendTransaction)
                }
            }
        }
    }
    
    func contactChanged(successfuly: Bool, sendTransaction :Bool) {
        if successfuly {
            _tempController = nil
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for cell in self.tableView.visibleCells {
                    (cell as! AddressCell).isEditable = false
                }
            })
            _isEditing = false
            _newContact = AddressBook.newContact
            AddressBook.newContact = nil

            self.filterChanged(self)
            
            if sendTransaction {
                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                    
                    let correspondent :Correspondent = Correspondent()
                    
                    for email in _newContact!.emailAddresses{
                        if email.label == "NEM" {
                            correspondent.address = (email.value as? String) ?? " "
                            correspondent.name = correspondent.address.nemName()
                        }
                    }
                    State.currentContact = correspondent
                    
                    (self.delegate as! MainVCDelegate).pageSelected(SegueToSendTransaction)
                }
            }
        }
    }
    
    func popUpClosed(successfuly :Bool)
    {
        if _tempController != nil {
            _tempController!.view.removeFromSuperview()
            _tempController!.removeFromParentViewController()
            _tempController = nil
        }
    }
    
    // MARK: - EditableTableViewCellDelegate Methods
    
    final func deleteCell(cell: EditableTableViewCell) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ADDRESSBOOK".localized(), (cell as! AddressCell).infoLabel.text!), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let index :NSIndexPath = self.tableView.indexPathForCell(cell)!
            
            if index.row < self.displayList.count {
                AddressBookManager.deleteContact(self.displayList[index.row], responce: nil)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.displayList.removeAtIndex(index.row)
                    self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)
                    
                })
            }
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - APIManagerDelegate Methods
    
    final func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        _walletData = account
    }
}

