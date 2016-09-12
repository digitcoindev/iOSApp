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
class AddressBookViewController: UIViewController, UIAlertViewDelegate, EditableTableViewCellDelegate, AddCustomContactDelegate {
    
    // MARK: - View Controller Properties
    
    private var contacts = [CNContact]()
    
    private var _tempController: UIViewController? = nil
    private var _walletData :AccountGetMetaData!
    private var _isEditing = false
    
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
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewControllerAppearanceOnViewWillAppear()
        createBarButtonItem()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller on view did load.
    private func updateViewControllerAppearanceOnViewDidLoad() {
        
        tabBarController?.title = "ADDRESS_BOOK".localized()
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "EDIT".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editButtonTouchUpInside(_:)))
        addContactButton.setTitle("  " + "ADD_CONTACT".localized(), forState: UIControlState.Normal)
        searchTextField.placeholder = "SEARCH_CONTACTS".localized()
        
        tableView.separatorInset.right = 15
    }
    
    /// Updates the appearance (coloring, titles) of the view controller on view will appear.
    private func updateViewControllerAppearanceOnViewWillAppear() {
        
        tabBarController?.title = "ADDRESS_BOOK".localized()
    }
    
    /// Creates and adds the edit bar button item to the view controller.
    private func createBarButtonItem() {
        
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "EDIT".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(editButtonTouchUpInside(_:)))
    }
    
    final private func _sendMessageTo(contact: CNContact)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddressBookMessageViewController =  storyboard.instantiateViewControllerWithIdentifier("AddressBookMessageViewController") as! AddressBookMessageViewController
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
        
        let contactCustomVC :AddressBookAddContactViewController =  storyboard.instantiateViewControllerWithIdentifier("AddressBookAddContactViewController") as! AddressBookAddContactViewController
        contactCustomVC.view.frame = CGRect(x: 0, y: view.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - view.frame.height)
        contactCustomVC.view.layer.opacity = 0
        //        contactCustomVC.delegate = self
        
        _tempController = contactCustomVC
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    final private func _changeContact(contact: CNContact)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let contactCustomVC :AddressBookAddContactViewController =  storyboard.instantiateViewControllerWithIdentifier("AddressBookAddContactViewController") as! AddressBookAddContactViewController
        contactCustomVC.view.frame = CGRect(x: 0, y: view.frame.height, width: contactCustomVC.view.frame.width, height: contactCustomVC.view.frame.height - view.frame.height)
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
        //        contactCustomVC.delegate = self
        
        _tempController = contactCustomVC
        self.view.addSubview(contactCustomVC.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            contactCustomVC.view.layer.opacity = 1
            }, completion: nil)
    }
    
    // MARK: - View Controller Outlet Actions

    @IBAction func endAction(sender: AnyObject) {
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
//        if _tempController != nil { return }
//
//        _isEditing = !_isEditing
//        
//        let title = _isEditing ? "DONE".localized() : "EDIT".localized()
//        tabBarController?.navigationItem.rightBarButtonItem!.title = title
//
//        for cell in self.tableView.visibleCells {
//            (cell as! AddressBookContactTableViewCell).isEditable = _isEditing
//        }
    }
    
    func filterChanged(sender: AnyObject) {
//        displayList.removeAll()
//        
//        AddressBookManager.refresh({ () -> Void in
//            self.contacts = AddressBookManager.contacts
//            
//            if self.contacts == nil || self.contacts!.count == 0 {
//                return
//            }
//            
//            for contact in self.contacts! {
//                var isValidValue = false
//                let needToAddSearchFilter = self.searchTextField.text != nil && self.searchTextField.text != ""
//                
//                if needToAddSearchFilter {
//                    //TODO: Fixed to Swift 2.2 in Version 2 Build 31 BETA, could be error
//                    
//                        if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(contact.givenName)
//                        {
//                            isValidValue = true
//                        }
//                    
//                        if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.searchTextField.text!).evaluateWithObject(contact.familyName)
//                        {
//                            isValidValue = true
//                        }
//                }
//                else {
//                    isValidValue = true
//                }
//                
//                if !isValidValue {
//                    continue
//                }
//                
//                self.displayList.append(contact)
//            }
//            
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                self.tableView.reloadData()
//            }
//        })
    }
    
    @IBAction func addNewContact(sender: AnyObject) {
        _addContact()
    }
    
    // MARK: -  AddCustomContactDelegate
    
    func contactAdded(successfuly: Bool, sendTransaction :Bool) {
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
    
    func contactChanged(successfuly: Bool, sendTransaction :Bool) {
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
//        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ADDRESSBOOK".localized(), (cell as! AddressBookContactTableViewCell).infoLabel.text!), preferredStyle: UIAlertControllerStyle.Alert)
//        
//        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            let index :NSIndexPath = self.tableView.indexPathForCell(cell)!
//            
//            if index.row < self.displayList.count {
//                AddressBookManager.deleteContact(self.displayList[index.row], responce: nil)
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.displayList.removeAtIndex(index.row)
//                    self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)
//                    
//                })
//            }
//            alert.dismissViewControllerAnimated(true, completion: nil)
//        }))
//        
//        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
//            alert.dismissViewControllerAnimated(true, completion: nil)
//        }))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - Table View Delegate

extension AddressBookViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AddressBookContactTableViewCell") as! AddressBookContactTableViewCell
        cell.contact = contacts[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell :AddressBookContactTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! AddressBookContactTableViewCell
        
//        if _isEditing || !cell.isAddress {
//            _changeContact(contacts[indexPath.row])
//        } else if _walletData != nil {
//            _sendMessageTo(contacts[indexPath.row])
//        }
    }
}
