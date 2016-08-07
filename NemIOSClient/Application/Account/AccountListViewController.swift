//
//  AccountListViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The account list view controller that shows a list with all available
    accounts which lets the user choose an account to further inspect.
 */
class AccountListViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    /// All accounts that will get listed in the table view.
    var accounts = [Account]()
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAccountButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accounts = AccountManager.sharedInstance.accounts()
        
        updateViewControllerAppearance()
        createEditButtonItemIfNeeded()
    }
    
    /// Needed for a smooth appearance of the alert view controller.
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /// Needed for a smooth appearance of the alert view controller.
    override func canResignFirstResponder() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "showAccountDetailTabBarController":
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destinationViewController as! AccountDetailTabBarController
                destinationViewController.account = accounts[indexPath.row]
            }
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        navigationItem.title = "ACCOUNTS".localized()
        addAccountButton.setTitle("   " + "ADD_ACCOUNT".localized(), forState: UIControlState.Normal)
    }
    
    /**
        Checks if there are any accounts to show and creates an edit button
        item on the right of the navigation bar if that's the case.
     */
    private func createEditButtonItemIfNeeded() {
        
        if (accounts.count > 0) {
            navigationItem.rightBarButtonItem = editButtonItem()
        }
    }
    
    /**
        Asks the user for confirmation of the deletion of an account and deletes 
        the account accordingly from both the table view and the database.
     
        - Parameter indexPath: The index path of the account that should get removed and deleted.
     */
    private func deleteAccount(atIndexPath indexPath: NSIndexPath) {
        
        let account = accounts[indexPath.row]
        
        let accountDeletionAlert = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ACCOUNTS".localized(), account.title), preferredStyle: .Alert)
        
        accountDeletionAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .Cancel, handler: nil))
        
        accountDeletionAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Destructive, handler: { (action) in
            
            self.accounts.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            
            AccountManager.sharedInstance.delete(account)
        }))
        
        presentViewController(accountDeletionAlert, animated: true, completion: nil)
    }
    
    /**
        Moves an account from its previous position in the array to the new position
        and saves that change in the database.
     
        - Parameter sourceIndexPath: The previous index path of the account (before the move).
        - Parameter destinationIndexPath: The new index path of the account (after the move)
     */
    private func moveAccount(fromPosition sourceIndexPath: NSIndexPath, toPosition destinationIndexPath: NSIndexPath) {
        
        if sourceIndexPath == destinationIndexPath {
            return
        }
        
        let moveableAccount = accounts[sourceIndexPath.row]
        accounts.removeAtIndex(sourceIndexPath.row)
        accounts.insert(moveableAccount, atIndex: destinationIndexPath.row)
        
        AccountManager.sharedInstance.updatePosition(forAccounts: accounts)
    }
    
    /**
        Asks the user to change the title for an existing account and makes
        the change accordingly.
     
        - Parameter indexPath: The index path of the account that should get updated.
     */
    private func changeTitle(forAccountAtIndexPath indexPath: NSIndexPath) {
        
        let account = accounts[indexPath.row]
        
        let accountTitleChangerAlert = UIAlertController(title: "CHANGE".localized(), message: "INPUT_NEW_ACCOUNT_NAME".localized(), preferredStyle: .Alert)
        
        accountTitleChangerAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .Cancel, handler: nil))
        
        accountTitleChangerAlert.addAction(UIAlertAction(title: "OK".localized(), style: .Default, handler: { (action) in
            
            let titleTextField = accountTitleChangerAlert.textFields![0] as UITextField
            if let newTitle = titleTextField.text {
                
                self.accounts[indexPath.row].title = newTitle
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
                AccountManager.sharedInstance.updateTitle(forAccount: self.accounts[indexPath.row], withNewTitle: newTitle)
            }
        }))
        
        accountTitleChangerAlert.addTextFieldWithConfigurationHandler { (textField) in
            textField.text = account.title
        }
        
        presentViewController(accountTitleChangerAlert, animated: true, completion: nil)
    }
    
    // MARK: - View Controller Outlet Actions
    
    /**
        Unwinds to the account list view controller and reloads all
        accounts to show.
     */
    @IBAction func unwindToAccountListViewController(segue: UIStoryboardSegue) {
        
        accounts = AccountManager.sharedInstance.accounts()
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source

extension AccountListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("AccountTableViewCell") as! AccountTableViewCell
        cell.title = accounts[indexPath.row].title
        
        return cell
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            
            deleteAccount(atIndexPath: indexPath)
            
        default:
            return
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        moveAccount(fromPosition: sourceIndexPath, toPosition: destinationIndexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

// MARK: - Table View Delegate

extension AccountListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.editing {
            changeTitle(forAccountAtIndexPath: indexPath)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            performSegueWithIdentifier("showAccountDetailTabBarController", sender: nil)
        }
    }
}
