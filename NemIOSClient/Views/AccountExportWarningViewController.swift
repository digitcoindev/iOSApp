//
//  AccountExportWarningViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AccountExportWarningViewController: UIViewController {
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningMessageText: UITextView!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningLabel.text = "   " + "WARNING".localized()
        
        let fontLight = UIFont(name: "HelveticaNeue-Light", size: 16)!
        let color = UIColor(red: 186 / 256, green: 0, blue: 0, alpha: 1)
        
        var atributes :[String:AnyObject] = [
            NSFontAttributeName : fontLight
        ]
        
        var message = "PRIVATE_KEY_SECURITY_WARNING_PART_ONE".localized()
        let atributedText = NSMutableAttributedString(string: message, attributes: atributes)
       
        atributes = [
            NSForegroundColorAttributeName : color,
            NSFontAttributeName:fontLight
        ]
        
        message = "PRIVATE_KEY_SECURITY_WARNING_PART_TWO".localized()
        atributedText.appendAttributedString(NSMutableAttributedString(string: message, attributes: atributes))
        
        atributes = [
            NSFontAttributeName:fontLight
        ]
        
        
        message = "PRIVATE_KEY_SECURITY_WARNING_PART_THREE".localized()
        atributedText.appendAttributedString(NSMutableAttributedString(string: message, attributes: atributes))
        
        atributes = [
            NSForegroundColorAttributeName : color,
            NSFontAttributeName:fontLight
        ]
        
        message = "PRIVATE_KEY_SECURITY_WARNING_PART_FOUR".localized()
        atributedText.appendAttributedString(NSMutableAttributedString(string: message, attributes: atributes))
        
        warningMessageText.attributedText = atributedText
        
        saveBtn.setTitle("SHOW_PRIVATE_KEY".localized(), forState: UIControlState.Normal)
        
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
    
    @IBAction func showKey(sender: AnyObject) {
        
//        (self.delegate as! AccountExportViewController).showPrivateKeyButn.setTitle("HIDE_PRIVATE_KEY".localized(), forState: UIControlState.Normal)
//        (self.delegate as! AccountExportViewController).privateKey.hidden = false
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}