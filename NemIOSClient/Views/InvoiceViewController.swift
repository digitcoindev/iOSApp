//
//  QRViewController.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 07.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class InvoiceViewController: AbstractViewController {

    @IBOutlet weak var actionBar: UISegmentedControl!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var createInvoiceContainerView: UIView!
    @IBOutlet weak var scanInvoiceContainerView: UIView!
    
//    private var _pages :QRContainerVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        actionBar.removeBorders()
        
        actionBar.setTitle("MY_INFO".localized(), forSegmentAtIndex: 0)
        actionBar.setTitle("NEW_INVOICE".localized(), forSegmentAtIndex: 1)
        actionBar.setTitle("SCAN_QR".localized(), forSegmentAtIndex: 2)
        
        infoContainerView.hidden = false
        createInvoiceContainerView.hidden = true
        scanInvoiceContainerView.hidden = true
        
        tabBarController?.title = "MY_INFO".localized()
        
//        switch State.toVC {
//        case SegueToUserInfo:
//            actionBar.selectedSegmentIndex = 0
//            tabBarController?.title = "MY_INFO".localized()
//            
//        case SegueToCreateInvoice, SegueToCreateInvoiceResult:
//            actionBar.selectedSegmentIndex = 1
//            tabBarController?.title = "NEW_INVOICE".localized()
//            
//        case SegueToScanQR:
//            actionBar.selectedSegmentIndex = 2
//            tabBarController?.title = "SCAN_QR".localized()
//            
//        default:
//            break
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        switch actionBar.selectedSegmentIndex {
        case 0 :

            tabBarController?.title = "MY_INFO".localized()
            
        case 1 :

            tabBarController?.title = "NEW_INVOICE".localized()
            
        case 2 :
            
            tabBarController?.title = "SCAN_QR".localized()
            
        default:
            break
        }
        
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    @IBAction func handleView(sender: UISegmentedControl) {
        switch actionBar.selectedSegmentIndex {
        case 0 :
            
            infoContainerView.hidden = false
            createInvoiceContainerView.hidden = true
            scanInvoiceContainerView.hidden = true
            
            tabBarController?.title = "MY_INFO".localized()
            
        case 1 :
            
            createInvoiceContainerView.hidden = false
            infoContainerView.hidden = true
            scanInvoiceContainerView.hidden = true

            tabBarController?.title = "NEW_INVOICE".localized()
            
        case 2 :
            
            scanInvoiceContainerView.hidden = false
            infoContainerView.hidden = true
            createInvoiceContainerView.hidden = true
            
            tabBarController?.title = "SCAN_QR".localized()

        default:
            break
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
//        if(segue.identifier == "QR Controller") {
//            _pages = segue.destinationViewController as! QRContainerVC
//            _pages.delegate = self
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
//    
//    final func changePage(page :String) {
//        _pages.changePage(page)
//    }
}
