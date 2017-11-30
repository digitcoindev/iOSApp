//
//  InvoiceViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class InvoiceViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var invoice: NewInvoice?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var invoiceQRCodeImageView: UIImageView!
    @IBOutlet weak var invoiceRecipientLabel: UILabel!
    @IBOutlet weak var invoiceAmountLabel: UILabel!
    @IBOutlet weak var invoiceMessageLabel: UILabel!
    @IBOutlet weak var shareInvoiceButton: UIButton!
    @IBOutlet weak var editInvoiceButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateAppearance()
        reloadInvoiceDetails()
        generateQRCode(forInvoice: invoice!)
    }
    
    // MARK: - View Controller Helper Methods
    
    ///
    private func reloadInvoiceDetails() {
        
        informationLabel.text = "Your correspondent is able to scan this QR code with his mobile wallet to pay your invoice"
        invoiceRecipientLabel.text = invoice?.recipient ?? ""
        invoiceAmountLabel.text = "\(invoice?.amount.format() ?? "0") XEM"
        invoiceMessageLabel.text = invoice?.message != "" ? invoice?.message ?? "-" : "-"
    }
    
    /**
         Generates the QR code image for the invoice.
     
         - Parameter invoice: The invoice for which the QR code image should get genererated.
     */
    fileprivate func generateQRCode(forInvoice invoice: NewInvoice) {
        
        let invoiceDictionary: [String: String] = [
            QRKeys.address.rawValue : account?.address ?? "",
            QRKeys.name.rawValue : invoice.recipient,
            QRKeys.amount.rawValue : "\(invoice.amount ?? 0.0 * 1000000)",
            QRKeys.message.rawValue : invoice.message
        ]
        
        let jsonDictionary = NSDictionary(objects: [QRType.invoice.rawValue, invoiceDictionary, Constants.qrVersion], forKeys: [QRKeys.dataType.rawValue as NSCopying, QRKeys.data.rawValue as NSCopying, QRKeys.version.rawValue as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        invoiceQRCodeImageView.image = String(data: jsonData, encoding: String.Encoding.utf8)!.createQRCodeImage()
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        shareInvoiceButton.layer.cornerRadius = 10.0
        editInvoiceButton.layer.cornerRadius = 10.0
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func shareInvoice(_ sender: UIButton) {
        
        if let qrCodeImage = invoiceQRCodeImageView.image {
            
            let message = "INVOICE_HEADER".localized()
            
            let shareActivityViewController = UIActivityViewController(activityItems: [message, qrCodeImage], applicationActivities: [])
            
            present(shareActivityViewController, animated: true)
        }
    }
}
