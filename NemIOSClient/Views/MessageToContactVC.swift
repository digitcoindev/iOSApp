//
//  MessageToContactVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 06.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class MessageToContactVC: AbstractViewController {

    //MARK: - @IBOutlet

    @IBOutlet weak var userInfoLabel: NEMLabel!
    @IBOutlet weak var userAddressLabel: NEMLabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionButton.setTitle("SEND_MESSAGE".localized(), forState: UIControlState.Normal)
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
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
    
    @IBAction func sendMessage(sender: AnyObject) {
        if Validate.address(userAddressLabel.text) {
            let correspondent :Correspondent = Correspondent()
            correspondent.address = userAddressLabel.text!
            correspondent.name = userInfoLabel.text!
            State.currentContact = correspondent
                        
            State.nextVC = SegueToSendTransaction
            
            if (self.delegate as! AbstractViewController).delegate != nil && (self.delegate as! AbstractViewController).delegate!.respondsToSelector("pageSelected:") {
                ((self.delegate as! AbstractViewController).delegate as! MainVCDelegate).pageSelected(SegueToPasswordValidation)
            }
        }
    }
    
    //MARK: - Private Helpers

    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
