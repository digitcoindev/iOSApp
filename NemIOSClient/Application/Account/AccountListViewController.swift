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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
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
    
    // TODO:
    
    func deleteCell(cell: EditableTableViewCell){
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ACCOUNTS".localized(), (cell as! AccountTableViewCell).titleLabel.text!), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let index :NSIndexPath = self.tableView.indexPathForCell(cell)!
            
            if index.row < self.accounts.count {
                if let loadData = State.loadData {
                    if loadData.currentWallet == self.accounts[index.row] {
                        loadData.currentWallet = nil
//                        self.dataManager.commit()
                    }
                }
//                self.dataManager.deleteWallet(wallet: self.wallets[index.row])
                self.accounts.removeAtIndex(index.row)
                
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)
            }
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
//        wallets  = dataManager.getWallets()
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            
            print("Delete")
            
        default:
            return
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        print("Move")
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
            
            print("Editing")
            
        } else {
            performSegueWithIdentifier("showAccountDetailTabBarController", sender: nil)
        }
    }
}
