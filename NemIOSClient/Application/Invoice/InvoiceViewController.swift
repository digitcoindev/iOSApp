//
//  InvoiceViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class InvoiceViewController: UIViewController {

    @IBOutlet weak var actionBar: UISegmentedControl!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var createInvoiceContainerView: UIView!
    @IBOutlet weak var scanInvoiceContainerView: UIView!
    
//    private var _pages :QRContainerVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        actionBar.removeBorders()
        
        actionBar.setTitle("MY_INFO".localized(), forSegmentAt: 0)
        actionBar.setTitle("NEW_INVOICE".localized(), forSegmentAt: 1)
        actionBar.setTitle("SCAN_QR".localized(), forSegmentAt: 2)
        
        infoContainerView.isHidden = false
        createInvoiceContainerView.isHidden = true
        scanInvoiceContainerView.isHidden = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
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

    @IBAction func handleView(_ sender: UISegmentedControl) {
        switch actionBar.selectedSegmentIndex {
        case 0 :
            
            infoContainerView.isHidden = false
            createInvoiceContainerView.isHidden = true
            scanInvoiceContainerView.isHidden = true
            
            tabBarController?.title = "MY_INFO".localized()
            
        case 1 :
            
            createInvoiceContainerView.isHidden = false
            infoContainerView.isHidden = true
            scanInvoiceContainerView.isHidden = true

            tabBarController?.title = "NEW_INVOICE".localized()
            
        case 2 :
            
            scanInvoiceContainerView.isHidden = false
            infoContainerView.isHidden = true
            createInvoiceContainerView.isHidden = true
            
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
