//
//  AddressBookMessageViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AddressBookMessageViewController: UIViewController {

    //MARK: - @IBOutlet

    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var userAddressLabel: UITextView!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionButton.setTitle("SEND_MESSAGE".localized(), forState: UIControlState.Normal)
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: #selector(AddressBookMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(AddressBookMessageViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
//        (self.delegate as! AddCustomContactDelegate).popUpClosed(true)

        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        guard let address = userAddressLabel.text?.stringByReplacingOccurrencesOfString("-", withString: "") else { return }

        if Validate.address(address) {
            let correspondent :Correspondent = Correspondent()
            correspondent.address = address
            correspondent.name = userInfoLabel.text!
            State.currentContact = correspondent
                                    
//            if (self.delegate as! AbstractViewController).delegate != nil && (self.delegate as! AbstractViewController).delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                ((self.delegate as! AbstractViewController).delegate as! MainVCDelegate).pageSelected(SegueToSendTransaction)
//            }
            
            performSegueWithIdentifier("showTransactionSendViewController", sender: nil)
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
