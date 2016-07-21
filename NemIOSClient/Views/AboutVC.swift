//
//  AboutVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 18.01.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class AboutVC: AbstractViewController {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var infoLabel: NEMLabel!
    @IBOutlet weak var userAddressLabel: NEMLabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        
        infoLabel.text = "VERSION".localized() + " " + versionNumber + " " + "BUILD".localized() + " " + buildNumber + "BETA"
        actionButton.setTitle("OK".localized(), forState: UIControlState.Normal)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func okAction(sender: AnyObject) {
        closePopUp(self)
    }
}