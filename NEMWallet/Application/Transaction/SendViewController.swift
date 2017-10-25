//
//  SendViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class SendViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var accountBalance = Double()
    public var accountFiatBalance = Double()
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var createTransactionView: UIView!
    @IBOutlet weak var createInvoiceView: UIView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showCreateTransactionViewController":
            
            let destinationViewController = segue.destination as! CreateTransactionViewController
            destinationViewController.account = account
            destinationViewController.accountBalance = accountBalance
            destinationViewController.accountFiatBalance = accountFiatBalance
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func selectedMenuChanged(_ sender: UISegmentedControl) {
        
        NotificationCenter.default.post(name: Constants.hideKeyboardNotification, object: nil)
        
        switch sender.selectedSegmentIndex {
        case 0:
            createTransactionView.isHidden = false
            createInvoiceView.isHidden = true
            break
            
        case 1:
            createTransactionView.isHidden = true
            createInvoiceView.isHidden = false
            break
            
        default:
            break
        }
    }
}
