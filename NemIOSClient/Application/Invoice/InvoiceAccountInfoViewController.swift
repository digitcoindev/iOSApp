//
//  InvoiceAccountInfoViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The view controller that lets the user look up information
    about his account and also share that information with others.
 */
class InvoiceAccountInfoViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    var account: Account!
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var accountAddressHeadingLabel: UILabel!
    @IBOutlet weak var accountTitleHeadingLabel: UILabel!
    @IBOutlet weak var accountAddressLabel: UILabel!
    @IBOutlet weak var accountTitleTextField: UITextField!
    @IBOutlet weak var accountQRCodeImageView: UIImageView!
    @IBOutlet weak var saveAccountQRCodeButton: UIButton!
    @IBOutlet weak var shareAccountQRCodeButton: UIButton!
    @IBOutlet weak var copyAccountAddressButton: UIButton!
    @IBOutlet weak var shareAccountAddressButton: UIButton!
    @IBOutlet weak var editAccountTitleButton: UIButton!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountManager.sharedInstance.activeAccount
        
        guard account != nil else {
            print("Critical: Account not available!")
            return
        }

        updateViewControllerAppearance()
        
        accountAddressLabel.text = account.address.nemAddressNormalised()
        accountTitleTextField.placeholder = account.title
        generateQRCode(forAccount: account)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller on view did load.
    fileprivate func updateViewControllerAppearance() {
        
        accountAddressHeadingLabel.text = "\("MY_ADDRESS".localized()):"
        accountTitleHeadingLabel.text = "\("MY_NAME".localized()):"
        accountTitleTextField.placeholder = "YOUR_NAME".localized()
        saveAccountQRCodeButton.setTitle("SAVE_QR".localized(), for: UIControlState())
        shareAccountQRCodeButton.setTitle("SHARE_QR".localized(), for: UIControlState())
        copyAccountAddressButton.setTitle("COPY_ADDRESS".localized(), for: UIControlState())
        shareAccountAddressButton.setTitle("SHARE_ADDRESS".localized(), for: UIControlState())
    }
    
    /**
        Generates the QR code image for the provided account.
     
        - Parameter account: The account for which the QR code image should get genererated.
     */
    fileprivate func generateQRCode(forAccount account: Account) {
        
        let accountDictionary: [String: String] = [
            QRKeys.Address.rawValue: account.address,
            QRKeys.Name.rawValue: accountTitleTextField.text != "" ? accountTitleTextField.text! : account.title
        ]
        
        let jsonDictionary = NSDictionary(objects: [QRType.userData.rawValue, accountDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue as NSCopying, QRKeys.Data.rawValue as NSCopying, QRKeys.Version.rawValue as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let qrCodeScannerView = QRCodeScannerView()
        accountQRCodeImageView.image = qrCodeScannerView.createQRCodeImage(fromCaptureResult: String(data: jsonData, encoding: String.Encoding.utf8)!)
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func editAccountTitleButtonPressed(_ sender: UIButton) {
        
        accountTitleTextField.becomeFirstResponder()
    }
    
    @IBAction func accountTitleHasChanged(_ sender: UITextField) {
        
        guard sender.text != nil else { return }
        
        generateQRCode(forAccount: account)
    }
    
    @IBAction func copyAccountAddress(_ sender: AnyObject) {
        
        let pasteBoard: UIPasteboard = UIPasteboard.general
        pasteBoard.string = account.address
    }
    
    @IBAction func shareAccountAddress(_ sender: UIButton) {
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let shareVC :ShareViewController =  storyboard.instantiateViewController(withIdentifier: "SharePopUp") as! ShareViewController
//        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
//        shareVC.view.layer.opacity = 0
//        //        shareVC.delegate = self
//        
//        shareVC.message = userAddress.text
//        popup = shareVC
//        
//        DispatchQueue.main.async(execute: { () -> Void in
//            self.view.addSubview(shareVC.view)
//            
//            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                shareVC.view.layer.opacity = 1
//                }, completion: nil)
//        })
    }
    
    @IBAction func saveAccountQRCodeImage(_ sender: UIButton) {
        
        guard accountQRCodeImageView.image != nil else { return }
        
        UIImageWriteToSavedPhotosAlbum(accountQRCodeImageView.image!, nil, nil, nil)
    }
    
    @IBAction func shareAccountQRCodeImage(_ sender: UIButton) {
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let shareVC :ShareViewController =  storyboard.instantiateViewController(withIdentifier: "SharePopUp") as! ShareViewController
//        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
//        shareVC.view.layer.opacity = 0
//        //        shareVC.delegate = self
//        
//        shareVC.message = (Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login) + ": " + address
//        shareVC.images = [qrImageView.image!]
//        popup = shareVC
//        
//        DispatchQueue.main.async(execute: { () -> Void in
//            self.view.addSubview(shareVC.view)
//            
//            UIView.animate(withDuration: 0.5, animations: { () -> Void in
//                shareVC.view.layer.opacity = 1
//                }, completion: nil)
//        })
    }
}
