//
//  AddAccountViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class AddAccountViewController: UIViewController {
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var createAccountView: UIView!
    @IBOutlet weak var importAccountByQRView: UIView!
    @IBOutlet weak var importAccountByPKView: UIView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func selectedMenuChanged(_ sender: UISegmentedControl) {
        
        NotificationCenter.default.post(name: Constants.hideKeyboardNotification, object: nil)
        
        switch sender.selectedSegmentIndex {
        case 0:
            createAccountView.isHidden = false
            importAccountByQRView.isHidden = true
            importAccountByPKView.isHidden = true
            break
            
        case 1:
            createAccountView.isHidden = true
            importAccountByQRView.isHidden = false
            importAccountByPKView.isHidden = true
            break
            
        case 2:
            createAccountView.isHidden = true
            importAccountByQRView.isHidden = true
            importAccountByPKView.isHidden = false
            break
            
        default:
            break
        }
    }
}
