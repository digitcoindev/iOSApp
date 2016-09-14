//
//  InvoiceCreatedViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Social
import MessageUI

class InvoiceCreatedViewController: UIViewController, MFMailComposeViewControllerDelegate
{
    // MARK: - @IBOutlet
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var invoiceDataLabel: UILabel!
    @IBOutlet weak var copyQRButton: UIButton!
    @IBOutlet weak var shareQRButton: UIButton!
    
    // MARK: - Private Variables
    
    fileprivate var invoice = State.invoice
    fileprivate var popup :UIViewController? = nil

    // MARK: - Load Metods
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        State.fromVC = SegueToCreateInvoice

        invoiceDataLabel.text = "INVOICE_DATA".localized()
        copyQRButton.setTitle("SAVE_QR".localized(), for: UIControlState())
        shareQRButton.setTitle("SHARE_QR".localized(), for: UIControlState())
        
        if invoice != nil {
            _generateQR()
            State.invoice = nil
            
            var titleText :NSMutableAttributedString = NSMutableAttributedString(string: "NAME".localized() + ": " , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 10)!])
            var contentText :NSMutableAttributedString = NSMutableAttributedString(string: invoice!.name , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 20)!])
            
            titleText.append(contentText)
            nameLabel.attributedText = titleText
            
            titleText = NSMutableAttributedString(string: "AMOUNT".localized() + ": " , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 10)!])
            contentText = NSMutableAttributedString(string: "\((invoice!.amount / 1000000).format()) XEM" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 20)!])
            
            titleText.append(contentText)
            amountLabel.attributedText = titleText
            
            titleText = NSMutableAttributedString(string: "MESSAGE".localized() + ": " , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 10)!])
            contentText = NSMutableAttributedString(string: invoice!.message , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 20)!])
            
            titleText.append(contentText)
            messageLabel.attributedText = titleText
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueToCreateInvoiceResult

    }
    
    // MARK: - @IBAction
    
    @IBAction func copyQR(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(qrImageView.image!, nil, nil, nil)
    }
    
    @IBAction func shareQR(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewController(withIdentifier: "SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
//        shareVC.delegate = self
        
        shareVC.message = "INVOICE_HEADER".localized()
        shareVC.images = [qrImageView.image!]
        popup = shareVC
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
    
    // MARK: -  Private Helpers
    
    fileprivate final func _generateQR()
    {
        let userDictionary: [String : AnyObject] = [
            QRKeys.Address.rawValue : invoice!.address as AnyObject,
            QRKeys.Name.rawValue : invoice!.name as AnyObject,
            QRKeys.Amount.rawValue : invoice!.amount as AnyObject,
            QRKeys.Message.rawValue : invoice!.message as AnyObject
        ]
        
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.invoice.rawValue, userDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue, QRKeys.Version.rawValue])
        
        let jsonData :Data = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions())
        
        let qr :QRCodeScannerView = QRCodeScannerView()
        
        qrImageView.image =  qr.createQRCodeImage(fromCaptureResult: String(data: jsonData, encoding: String.Encoding.utf8)!)

    }
    
    // MARK: -  MFMailComposeViewControllerDelegate Methos
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
