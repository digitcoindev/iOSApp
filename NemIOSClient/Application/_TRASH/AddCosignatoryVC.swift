//
//  AddCosignatoryVC.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 14.01.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class AddCosignatoryVC: UIViewController {
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
        
        saveBtn.setTitle("CHANGE".localized(), for: UIControlState())
        
        let center: NotificationCenter = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(AddCosignatoryVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(AddCosignatoryVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func hideKeyboard(_ sender: AnyObject) {
        sender.endEditing(true)
    }
    
    @IBAction func saveChanges(_ sender: AnyObject) {
        
        if let value = Int(minCosig.text ?? "") {
            if value < minCosigValue || value > maxCosigValue {
                minCosig.text = ""
                return
            } else {
//                (self.delegate as! MultisignatureViewController).minCosig = value
            }
        } else {
            minCosig.text = ""
            return
        }
        

        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    //MARK: - Private Methods
    
    fileprivate func _failedWithError(_ text: String, completion :((Void) -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(_ notification: Notification) {
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.scroll.contentInset = UIEdgeInsets.zero
        self.scroll.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
