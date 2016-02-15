//
//  AddCosigPopUp.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 23.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

protocol AddCosigPopUptDelegate
{
    func addCosig(publicKey :String)
}

class AddCosigPopUp: AbstractViewController {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var publicKey: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicKey.placeholder = "   " + "INPUT_PUBLIC_KEY".localized()
        saveBtn.setTitle("ADD_COSIGNATORY".localized(), forState: UIControlState.Normal)
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func addCosig(sender: AnyObject) {
        if Validate.stringNotEmpty(publicKey.text) && Validate.hexString(publicKey.text!){
            (self.delegate as? AddCosigPopUptDelegate)?.addCosig(publicKey.text!)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
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

