//
//  InvoiceCreatedViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/**
    The view controller that shows the newly created invoice and lets
    the user share that invoice.
 */
class InvoiceCreatedViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    var invoice: Invoice!
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var invoiceQRCodeImageView: UIImageView!
    @IBOutlet weak var invoiceAccountTitleLabel: UILabel!
    @IBOutlet weak var invoiceAmountLabel: UILabel!
    @IBOutlet weak var invoiceMessageLabel: UILabel!
    @IBOutlet weak var invoiceDataHeadingLabel: UILabel!
    @IBOutlet weak var saveQRCodeImageButton: UIButton!
    @IBOutlet weak var shareQRCodeImageButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.delegate = self
        
        updateViewControllerAppearance()
        
        generateQRCode(forInvoice: invoice)
        
        let invoiceAccountTitleHeading = NSMutableAttributedString(string: "\("NAME".localized()): ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13)])
        let invoiceAccountTitle = NSMutableAttributedString(string: invoice.accountTitle, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        invoiceAccountTitleHeading.append(invoiceAccountTitle)
        invoiceAccountTitleLabel.attributedText = invoiceAccountTitleHeading
        
        let invoiceAmountHeading = NSMutableAttributedString(string: "\("AMOUNT".localized()): ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13)])
        let invoiceAmount = NSMutableAttributedString(string: "\((Double(invoice.amount) / 1000000).format()) XEM" , attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        invoiceAmountHeading.append(invoiceAmount)
        invoiceAmountLabel.attributedText = invoiceAmountHeading
        
        let invoiceMessageHeading = NSMutableAttributedString(string: "\("MESSAGE".localized()): ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13)])
        let invoiceMessage = NSMutableAttributedString(string: invoice.message, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        invoiceMessageHeading.append(invoiceMessage)
        invoiceMessageLabel.attributedText = invoiceMessageHeading
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewTopConstraint.constant = self.navigationBar.frame.height
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        invoiceDataHeadingLabel.text = "INVOICE_DATA".localized()
        saveQRCodeImageButton.setTitle("SAVE_QR".localized(), for: UIControlState())
        shareQRCodeImageButton.setTitle("SHARE_QR".localized(), for: UIControlState())
    }
    
    /**
        Generates the QR code image for the invoice.
     
        - Parameter invoice: The invoice for which the QR code image should get genererated.
     */
    fileprivate func generateQRCode(forInvoice invoice: Invoice) {
        
        let invoiceDictionary: [String: String] = [
            QRKeys.Address.rawValue : invoice.accountAddress,
            QRKeys.Name.rawValue : invoice.accountTitle,
            QRKeys.Amount.rawValue : "\(invoice.amount)",
            QRKeys.Message.rawValue : invoice.message
        ]
        
        let jsonDictionary = NSDictionary(objects: [QRType.invoice.rawValue, invoiceDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue as NSCopying, QRKeys.Data.rawValue as NSCopying, QRKeys.Version.rawValue as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let qrCodeScannerView = QRCodeScannerView()
        invoiceQRCodeImageView.image = qrCodeScannerView.createQRCodeImage(fromCaptureResult: String(data: jsonData, encoding: String.Encoding.utf8)!)
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func saveInvoiceQRCodeImage(_ sender: UIButton) {
        
        guard invoiceQRCodeImageView.image != nil else { return }
        
        UIImageWriteToSavedPhotosAlbum(invoiceQRCodeImageView.image!, nil, nil, nil)
    }
    
    @IBAction func shareInvoiceQRCodeImage(_ sender: UIButton) {
        
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //
        //        let shareVC :ShareViewController =  storyboard.instantiateViewController(withIdentifier: "SharePopUp") as! ShareViewController
        //        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        //        shareVC.view.layer.opacity = 0
        //
        //        shareVC.message = "INVOICE_HEADER".localized()
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
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Navigation Bar Delegate

extension InvoiceCreatedViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
