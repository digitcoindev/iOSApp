//
//  SettingsAddServerViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

@objc protocol AddCustomServerDelegate
{
    func serverAdded(successfuly :Bool)
    func popUpClosed()
}

class SettingsAddServerViewController: UIViewController, APIManagerDelegate
{
    //MARK: - @IBOutlet

    @IBOutlet weak var protocolType: UITextField!
    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var serverPort: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    //MARK: - Private Variables
    
    var newServer :Server? = nil
    private let _apiManager :APIManager = APIManager()
    private let _dataManager :CoreDataManager = CoreDataManager()
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.userInteractionEnabled = true

        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: #selector(SettingsAddServerViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(SettingsAddServerViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        _apiManager.delegate = self
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
//        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(AddCustomServerDelegate.serverAdded(_:))) {
//            (self.delegate as! AddCustomServerDelegate).popUpClosed()
//        }
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func textFieldChange(sender: UITextField) {
        switch sender {
        case protocolType:
            serverAddress.becomeFirstResponder()
            
        case serverAddress:
            serverPort.becomeFirstResponder()
            
        default:
            contentView.endEditing(false)
        }
    }
    
    @IBAction func addServer(sender: AnyObject) {
        if !Validate.stringNotEmpty(serverAddress.text) || !Validate.stringNotEmpty(serverPort.text) || !Validate.stringNotEmpty(protocolType.text) {
            let alert :UIAlertView = UIAlertView(title: "INFO".localized(), message: NSLocalizedString("FIELDS_EMPTY_ERROR", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else if protocolType.text != "http" {
            let alert :UIAlertView = UIAlertView(title: "INFO".localized(), message: NSLocalizedString("SERVER_PROTOCOL_NOT_AVAILABLE", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else {
            let servers :[Server] =  _dataManager.getServers()
            
            for server in servers {
                if server.protocolType == protocolType.text && server.address == serverAddress.text && server.port == serverPort.text {
                    newServer = server
                    
                    break
                }
            }
            
            if newServer == nil {
                newServer =  _dataManager.addServer(protocolType.text!, address: serverAddress.text! ,port: serverPort.text!)
            } else {
                newServer?.address = serverAddress.text!
                newServer?.port = serverPort.text!
                newServer?.protocolType = protocolType.text!
                
                _dataManager.commit()
            }
                        
//            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(AddCustomServerDelegate.serverAdded(_:))) {
//                (self.delegate as! AddCustomServerDelegate).serverAdded(true)
//            }
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            serverAddress.text = ""
            protocolType.text = "http"
            serverPort.text = "7890"
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
