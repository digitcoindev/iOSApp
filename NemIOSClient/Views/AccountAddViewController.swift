//
//  AccountAddViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AccountAddViewController: UIViewController
{
    //MARK: - IBOulets
    
    @IBOutlet weak var custom: UIButton!
    @IBOutlet weak var qr: UIButton!
    @IBOutlet weak var key: UIButton!

    //MARK: - Load Methods

    override func viewDidLoad(){
        super.viewDidLoad()
        
//        State.currentVC = SegueToAddAccountVC

        custom.layer.cornerRadius = 5
        qr.layer.cornerRadius = 5
        key.layer.cornerRadius = 5
        
        title = "ADD_ACCOUNT".localized()
        custom.setTitle("CREATE_NEW".localized(), forState: UIControlState.Normal)
        qr.setTitle("SCAN_QR_CODE".localized(), forState: UIControlState.Normal)
        key.setTitle("IMPORT_KEY".localized(), forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToAddAccountVC

    }
    
//    override func delegateIsSetted() {
// 
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
