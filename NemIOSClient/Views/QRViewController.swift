//
//  QRViewController.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 07.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class QRViewController: AbstractViewController {

    @IBOutlet weak var actionBar: UISegmentedControl!
    @IBOutlet weak var titleLable: UILabel!
    
    private var _pages :QRContainerVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionBar.removeBorders()
        
        switch State.toVC {
        case SegueToUserInfo:
            actionBar.selectedSegmentIndex = 0
            titleLable.text = "User Info"
            
        case SegueToCreateInvoice, SegueToCreateInvoiceResult:
            actionBar.selectedSegmentIndex = 1
            titleLable.text = "New Invoice"
            
        case SegueToScanQR:
            actionBar.selectedSegmentIndex = 2
            titleLable.text = "Scan QR"
            
        default:
            break
        }
    }

    @IBAction func handleView(sender: UISegmentedControl) {
        switch actionBar.selectedSegmentIndex {
        case 0 :
            _pages.changePage(SegueToUserInfo)
            titleLable.text = "User Info"
            
        case 1 :
            _pages.changePage(SegueToCreateInvoice)
            titleLable.text = "New Invoice"
            
        case 2 :
            _pages.changePage(SegueToScanQR)
            titleLable.text = "Scan QR"

        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if(segue.identifier == "QR Controller") {
            _pages = segue.destinationViewController as! QRContainerVC
            _pages.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMessages)
        }
    }
    
    final func changePage(page :String) {
        _pages.changePage(page)
    }
}
