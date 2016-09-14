//
//  AccountExportViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Social
import MessageUI

class AccountExportViewController: UIViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var privateKey: UITextView!
    @IBOutlet weak var publicKey: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var showPrivateKeyButn: UIButton!
    
    fileprivate var popup :UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qr :QRCodeScannerView = QRCodeScannerView()
        
        qrImage.image =  qr.createQRCodeImage(fromCaptureResult: State.exportAccount!)
        
        let priv_key = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let pub_key = KeyGenerator.generatePublicKey(priv_key!)
        privateKey.text = priv_key
        publicKey.text = pub_key
                
        shareButton.setTitle("SHARE_QR".localized(), for: UIControlState())
        copyButton.setTitle("SAVE_QR".localized(), for: UIControlState())
        title = "EXPORT_ACCOUNT".localized()
        publicKeyLabel.text = "PUBLIC_KEY".localized()
        showPrivateKeyButn.setTitle("VIEW_PRIVATE_KEY".localized(), for: UIControlState())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToExportAccount
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    @IBAction func showPrivateKey(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        if  !privateKey.isHidden {
            showPrivateKeyButn.setTitle("VIEW_PRIVATE_KEY".localized(), for: UIControlState())
            privateKey.isHidden = true
        } else {
            if popup != nil {
                popup!.view.removeFromSuperview()
                popup!.removeFromParentViewController()
                popup = nil
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let popUpController :UIViewController =  storyboard.instantiateViewController(withIdentifier: "AccountExportWarningViewController") 
            popUpController.view.frame = CGRect(x: 0, y: 40, width: popUpController.view.frame.width, height: popUpController.view.frame.height - 40)
            popUpController.view.layer.opacity = 0
//            popUpController.delegate = self
            
            popup = popUpController
            self.view.addSubview(popUpController.view)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                popUpController.view.layer.opacity = 1
                }, completion: nil)
        }
    }
    
    @IBAction func copyQR(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(qrImage.image!, nil, nil, nil)
    }
    
    @IBAction func shareQR(_ sender: AnyObject) {
        self.view.endEditing(true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewController(withIdentifier: "SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
//        shareVC.delegate = self
        
        shareVC.images = [qrImage.image!]
        popup = shareVC
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
}
