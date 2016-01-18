//
//  AddCosignatoryVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 14.01.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class AddCosignatoryVC: AbstractViewController {
    @IBOutlet weak var minCosig: NEMTextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    var minCosigValue = 0
    var maxCosigValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        minCosig.placeholder = "  " + "REPEAT_PASSWORD_PLACEHOLDER".localized()
        
        saveBtn.setTitle("CHANGE".localized(), forState: UIControlState.Normal)
        
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
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        sender.endEditing(true)
    }
    
    @IBAction func saveChanges(sender: AnyObject) {
        
        if let value = Int(minCosig.text ?? "") {
            if value < minCosigValue || value > maxCosigValue {
                minCosig.text = ""
                return
            } else {
                (self.delegate as! MultisigAccountManager).minCosig = value
            }
        } else {
            minCosig.text = ""
            return
        }
        
        (self.delegate as! MultisigAccountManager).submitChanges()

        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    //MARK: - Private Methods
    
    private func _failedWithError(text: String, completion :(Void -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion?()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
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
