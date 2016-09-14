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

    fileprivate var address :String!
    fileprivate var popup :UIViewController? = nil
    
    // MARK: - Load Metods

    override func viewDidLoad() {
        super.viewDidLoad()
//        State.fromVC = SegueToUserInfo

        myAddressLabel.text = "MY_ADDRESS".localized() + ":"
        myNameLabel.text = "MY_NAME".localized() + ":"
        userName.placeholder = "YOUR_NAME".localized()
        copyQRButton.setTitle("SAVE_QR".localized(), for: UIControlState())
        shareQRButton.setTitle("SHARE_QR".localized(), for: UIControlState())
        copyAddressButton.setTitle("COPY_ADDRESS".localized(), for: UIControlState())
        shareAddressButton.setTitle("SHARE_ADDRESS".localized(), for: UIControlState())
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let publicKey = KeyGenerator.generatePublicKey(privateKey!)
        address = AddressGenerator.generateAddress(publicKey)
        
        userAddress.text = address.nemAddressNormalised()
        userName.placeholder = State.currentWallet!.login
        
        _generateQR()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToUserInfo
    }
    
    // MARK: - @IBAction
    
    @IBAction func activeteField(_ sender: AnyObject) {
        userName.becomeFirstResponder()
    }

    @IBAction func nameChanged(_ sender: AnyObject) {
        userName.becomeFirstResponder()
        
        _generateQR()
    }
    
    @IBAction func copyAddress(_ sender: AnyObject) {
        let pasteBoard :UIPasteboard = UIPasteboard.general
        pasteBoard.string = address

    }
    
    @IBAction func shareAddress(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewController(withIdentifier: "SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
//        shareVC.delegate = self
        
        shareVC.message = userAddress.text
        popup = shareVC
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })        
    }
    
    @IBAction func copyQR(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(qrImageView.image!, nil, nil, nil)
    }
    
    @IBAction func shareQR(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewController(withIdentifier: "SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
//        shareVC.delegate = self
        
        shareVC.message = (Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login) + ": " + address
        shareVC.images = [qrImageView.image!]
        popup = shareVC
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
    
    fileprivate final func _generateQR()
    {
        let userDictionary: [String : String] = [
            QRKeys.Address.rawValue : address,
            QRKeys.Name.rawValue : Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login
        ]
        
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.userData.rawValue, userDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue, QRKeys.Version.rawValue])
        
        let jsonData :Data = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let qr :QRCodeScannerView = QRCodeScannerView()
        qrImageView.image =  qr.createQRCodeImage(fromCaptureResult: String(data: jsonData, encoding: String.Encoding.utf8)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
