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
    
    private var _pages :QRContainerVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionBar.removeBorders()
        
        switch State.toVC {
        case SegueToUserInfo:
            actionBar.selectedSegmentIndex = 0
        default:
            break
        }
    }

    @IBAction func hadleView(sender: UISegmentedControl) {
        switch actionBar.selectedSegmentIndex {
        case 0 :
            _pages.changePage(SegueToUserInfo)
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if(segue.identifier == "mainContainer") {
            _pages = segue.destinationViewController as! QRContainerVC
            _pages.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
}
