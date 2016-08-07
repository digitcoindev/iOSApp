//
//  InvoiceAccountInfoViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class InvoiceAccountInfoViewController: UIViewController
{
    // MARK: - @IBOutlet

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var myAddressLabel: UILabel!
    @IBOutlet weak var myNameLabel: UILabel!
    
    @IBOutlet weak var copyQRButton: UIButton!
    @IBOutlet weak var shareQRButton: UIButton!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var shareAddressButton: UIButton!
    
    // MARK: - Private Variables

    private var address :String!
    private var popup :UIViewController? = nil
    
    // MARK: - Load Metods

    override func viewDidLoad() {
        super.viewDidLoad()
//        State.fromVC = SegueToUserInfo

        myAddressLabel.text = "MY_ADDRESS".localized() + ":"
        myNameLabel.text = "MY_NAME".localized() + ":"
        userName.placeholder = "YOUR_NAME".localized()
        copyQRButton.setTitle("SAVE_QR".localized(), forState: UIControlState.Normal)
        shareQRButton.setTitle("SHARE_QR".localized(), forState: UIControlState.Normal)
        copyAddressButton.setTitle("COPY_ADDRESS".localized(), forState: UIControlState.Normal)
        shareAddressButton.setTitle("SHARE_ADDRESS".localized(), forState: UIControlState.Normal)
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let publicKey = KeyGenerator.generatePublicKey(privateKey!)
        address = AddressGenerator.generateAddress(publicKey)
        
        userAddress.text = address.nemAddressNormalised()
        userName.placeholder = State.currentWallet!.login
        
        _generateQR()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToUserInfo
    }
    
    // MARK: - @IBAction
    
    @IBAction func activeteField(sender: AnyObject) {
        userName.becomeFirstResponder()
    }

    @IBAction func nameChanged(sender: AnyObject) {
        userName.becomeFirstResponder()
        
        _generateQR()
    }
    
    @IBAction func copyAddress(sender: AnyObject) {
        let pasteBoard :UIPasteboard = UIPasteboard.generalPasteboard()
        pasteBoard.string = address

    }
    
    @IBAction func shareAddress(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
//        shareVC.delegate = self
        
        shareVC.message = userAddress.text
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })        
    }
    
    @IBAction func copyQR(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(qrImageView.image!, nil, nil, nil)
    }
    
    @IBAction func shareQR(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
//        shareVC.delegate = self
        
        shareVC.message = (Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login) + ": " + address
        shareVC.images = [qrImageView.image!]
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
    
    private final func _generateQR()
    {
        let userDictionary: [String : String] = [
            QRKeys.Address.rawValue : address,
            QRKeys.Name.rawValue : Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login
        ]
        
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.UserData.rawValue, userDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue, QRKeys.Version.rawValue])
        
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions.PrettyPrinted)
        
        let qr :QRCodeScannerView = QRCodeScannerView()
        qrImageView.image =  qr.createQRCodeImage(String(data: jsonData, encoding: NSUTF8StringEncoding)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
