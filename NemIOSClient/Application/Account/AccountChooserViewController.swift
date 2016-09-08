//
//  AccountChooserViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

protocol AccountChooserDelegate {
    func didChooseAccount(account: AccountData)
}

/// The view controller that lets the user choose from different listed accounts.
class AccountChooserViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    var delegate: AccountChooserDelegate?
    var accounts: [AccountData]? {
        didSet {
            updateTableView()
        }
    }
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads/Updates the table view.
    private func updateTableView() {
        
        guard accounts != nil else { return }
        
        tableView.reloadData()
    }
}

// MARK: - Table View Delegate

extension AccountChooserViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountTableViewCell") as! AccountTableViewCell
        cell.title = accounts![indexPath.row].title ?? accounts![indexPath.row].address.nemAddressNormalised()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        delegate?.didChooseAccount(accounts![indexPath.row])
        
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}
