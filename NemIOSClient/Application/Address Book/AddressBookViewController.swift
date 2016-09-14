//
//  AddressBookViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Contacts

/**
    The view controller that shows all available contacts with their corresponding 
    NEM account address. This view controller lets the user add new contacts or 
    send a transaction directly to a specific contact.
 */
class AddressBookViewController: UIViewController, UIAlertViewDelegate, AddCustomContactDelegate {
    
    // MARK: - View Controller Properties
    
    fileprivate var contacts = [CNContact]()
    
    fileprivate var _tempController: UIViewController? = nil
    fileprivate var _walletData :AccountGetMetaData!
    fileprivate var _isEditing = false
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchTextField: NEMTextField!
    @IBOutlet weak var addContactButton: UIButton!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewControllerAppearanceOnViewDidLoad()
        
        AddressBookManager.sharedInstance.contacts { [weak self] (contacts) in
            print(contacts)
            self?.contacts = contacts
            self?.tableView.reloadData()
            self?.createEditButtonItemIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewControllerAppearanceOnViewWillAppear()
        createEditButtonItemIfNeeded()
        
        if (tableView.indexPathForSelectedRow != nil) {
            let indexPath = tableView.indexPathForSelectedRow!
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller on view did load.
    fileprivate func updateViewControllerAppearanceOnViewDidLoad() {
        
        tabBarController?.title = "ADDRESS_BOOK".localized()
        addContactButton.setTitle("  " + "ADD_CONTACT".localized(), for: UIControlState())
        searchTextField.placeholder = "SEARCH_CONTACTS".localized()
        
        tableView.separatorInset.right = 15
    }
    
    /// Updates the appearance (coloring, titles) of the view controller on view will appear.
    fileprivate func updateViewControllerAppearanceOnViewWillAppear() {
        
        tabBarController?.title = "ADDRESS_BOOK".localized()
    }
    
    /**
        Checks if there are any contacts to show and creates an edit button
        item on the right of the navigation bar if that's the case.
     */
    fileprivate func createEditButtonItemIfNeeded() {
        
        if (contacts.count > 0) {
            tabBarController?.navigationItem.rightBarButtonItem = editButtonItem
        } else {
            tabBarController?.navigationItem.rightBarButtonItem = nil
        }
    }
    
    /**
        Asks the user for confirmation of the deletion of a contact and deletes
        the contact accordingly from both the table view and the database.
     
        - Parameter indexPath: The index path of the contact that should get removed and deleted.
     */
    fileprivate func deleteContact(atIndexPath indexPath: IndexPath) {
        
        let contact = contacts[(indexPath as NSIndexPath).row]
        
        let contactDeletionAlert = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ADDRESSBOOK".localized(), "\(contact.givenName) \(contact.familyName)"), preferredStyle: .alert)
        
        contactDeletionAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        
        contactDeletionAlert.addAction(UIAlertAction(title: "OK".localized(), style: .destructive, handler: { (action) in
            
            self.contacts.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath], with: .bottom)
            
//            AccountManager.sharedInstance.delete(account: account)
        }))
        
        present(contactDeletionAlert, animated: true, completion: nil)
    }
    
    /**
        Lets the user change/update a contact.
     
        - Parameter indexPath: The index path of the contact that should get updated.
     */
    fileprivate func updateContact(atIndexPath indexPath: IndexPath) {
        
        let contact = contacts[(indexPath as NSIndexPath).row]
        
//        let accountTitleChangerAlert = UIAlertController(title: "CHANGE".localized(), message: "INPUT_NEW_ACCOUNT_NAME".localized(), preferredStyle: .Alert)
//        
//        accountTitleChangerAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .Cancel, handler: nil))
//        
//        accountTitleChangerAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: { (action) in
//            
//            let titleTextField = accountTitleChangerAlert.textFields![0] as UITextField
//            if let newTitle = titleTextField.text {
//                
//                self.accounts[indexPath.row].title = newTitle
//                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                
//                AccountManager.sharedInstance.updateTitle(forAccount: self.accounts[indexPath.row], withNewTitle: newTitle)
//            }
//        }))
//        
//        accountTitleChangerAlert.addTextFieldWithConfigurationHandler { (textField) in
//            textField.text = account.title
//        }
//        
//        presentViewController(accountTitleChangerAlert, animated: true, completion: nil)
    }
    
    final fileprivate func _sendMessageTo(_ contact: CNContact)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddressBookMessageViewController =  storyboard.instantiateViewController(withIdentifier: "AddressBookMessageViewController") as! AddressBookMessageViewController
        contactCustomVC.view.frame = CGRect(x: 0, y: view.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - view.frame.height)
        contactCustomVC.view.layer.opacity = 0
        //        contactCustomVC.delegate = self
        _tempController = contactCustomVC
        
        contactCustomVC.userInfoLabel.text = contact.givenName + " " + contact.familyName
        
        for email in contact.emailAddresses{
            if email.label == "NEM" {
                contactCustomVC.userAddressLabel.text = (email.value as? String)?.nemAddressNormalised() ?? " "
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(contactCustomVC.view)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                contactCustomVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
    
    final fileprivate func _addContact()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddressBookUpdateContactViewController =  storyboard.instantiateViewController(withIdentifier: "AddressBookAddContactViewController") as! AddressBookUpdateContactViewController
        contactCustomVC.view.frame = CGRect(x: 0, y: view.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - view.frame.height)
        contactCustomVC.view.layer.opacity = 0
        //        contactCustomVC.delegate = self
        
        _tempController = contactCustomVC
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    final fileprivate func _changeContact(_ contact: CNContact)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddressBookUpdateContactViewController =  storyboard.instantiateViewController(withIdentifier: "AddressBookAddContactViewController") as! AddressBookUpdateContactViewController
        contactCustomVC.view.frame = CGRect(x: 0, y: view.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - view.frame.height)
        contactCustomVC.view.layer.opacity = 0
        contactCustomVC.firstName.text = contact.givenName
        contactCustomVC.lastName.text = contact.familyName
        
        for email in contact.emailAddresses{
            if email.label == "NEM" {
                contactCustomVC.address.text = email.value as? String ?? ""
            }
        }
        
        contactCustomVC.saveBtn.setTitle("CHANGE_CONTACT".localized(), for: UIControlState())
        contactCustomVC.contact = contact
        //        contactCustomVC.delegate = self
        
        _tempController = contactCustomVC
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    // MARK: - View Controller Outlet Actions

    @IBAction func endAction(_ sender: AnyObject) {
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func addNewContact(_ sender: AnyObject) {
        _addContact()
    }
    
    // MARK: -  AddCustomContactDelegate
    
    func contactAdded(_ successfuly: Bool, sendTransaction :Bool) {
//        if successfuly {
//            _tempController = nil
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                for cell in self.tableView.visibleCells {
//                    (cell as! AddressBookContactTableViewCell).isEditable = false
//                }
//            })
//            
//            _isEditing = false
//            _newContact = AddressBookViewController.newContact
//            AddressBookViewController.newContact = nil
//            
//            self.filterChanged(self)
//            
//            if sendTransaction {
////                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
////                    
////                    let correspondent :Correspondent = Correspondent()
////                    
////                    for email in _newContact!.emailAddresses{
////                        if email.label == "NEM" {
////                            correspondent.address = (email.value as? String) ?? " "
////                            correspondent.name = correspondent.address.nemName()
////                        }
////                    }
////                    State.currentContact = correspondent
////                    
//////                    (self.delegate as! MainVCDelegate).pageSelected(SegueToSendTransaction)
////                }
//            }
//        }
    }
    
    func contactChanged(_ successfuly: Bool, sendTransaction :Bool) {
//        if successfuly {
//            _tempController = nil
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                for cell in self.tableView.visibleCells {
//                    (cell as! AddressBookContactTableViewCell).isEditable = false
//                }
//            })
//            _isEditing = false
//            _newContact = AddressBookViewController.newContact
//            AddressBookViewController.newContact = nil
//
//            self.filterChanged(self)
//            
//            if sendTransaction {
////                if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
////                    
////                    let correspondent :Correspondent = Correspondent()
////                    
////                    for email in _newContact!.emailAddresses{
////                        if email.label == "NEM" {
////                            correspondent.address = (email.value as? String) ?? " "
////                            correspondent.name = correspondent.address.nemName()
////                        }
////                    }
////                    State.currentContact = correspondent
////                    
//////                    (self.delegate as! MainVCDelegate).pageSelected(SegueToSendTransaction)
////                }
//            }
//        }
    }
    
    func popUpClosed(_ successfuly :Bool)
    {
        if _tempController != nil {
            _tempController!.view.removeFromSuperview()
            _tempController!.removeFromParentViewController()
            _tempController = nil
        }
    }
}

// MARK: - Table View Delegate

extension AddressBookViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressBookContactTableViewCell") as! AddressBookContactTableViewCell
        cell.contact = contacts[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            
            deleteContact(atIndexPath: indexPath)
            
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DIDSELECT")
        if tableView.isEditing {
            performSegue(withIdentifier: "showAddressBookUpdateContactViewController", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
//            performSegueWithIdentifier("showAccountDetailTabBarController", sender: nil)
        }
        
//        if _isEditing || !cell.isAddress {
//            _changeContact(contacts[indexPath.row])
//        } else if _walletData != nil {
//            _sendMessageTo(contacts[indexPath.row])
//        }
    }
}
