//
//  ShareAccountDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class ShareAccountDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var accountDetailsQRCodeImageView: UIImageView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountAddressLabel: UILabel!
    @IBOutlet weak var shareAccountDetailsButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadAccountDetails()
        generateQRCode()
    }
    
    // MARK: - View Controller Helper Methods
    
    ///
    private func reloadAccountDetails() {
        
        informationLabel.text = "Your correspondent is able to scan this QR code with his mobile wallet to save your account details in his address book"
        accountNameLabel.text = account?.title ?? "-"
        accountAddressLabel.text = account?.address.nemAddressNormalised() ?? "-"
    }
    
    /// Generates the QR code image for the account details.
    fileprivate func generateQRCode() {
        
        let accountDictionary: [String: String] = [
            QRKeys.address.rawValue: account?.address ?? "-",
            QRKeys.name.rawValue: account?.title ?? "-"
        ]
        
        let jsonDictionary = NSDictionary(objects: [QRType.userData.rawValue, accountDictionary, Constants.qrVersion], forKeys: [QRKeys.dataType.rawValue as NSCopying, QRKeys.data.rawValue as NSCopying, QRKeys.version.rawValue as NSCopying])
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)

        accountDetailsQRCodeImageView.image = String(data: jsonData, encoding: String.Encoding.utf8)!.createQRCodeImage()
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        shareAccountDetailsButton.layer.cornerRadius = 10.0
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func shareAccountDetails(_ sender: UIButton) {
        
        if let qrCodeImage = accountDetailsQRCodeImageView.image {
            
            let message = "\(account?.title ?? "-"): \(account?.address.nemAddressNormalised() ?? "-")"
            let shareActivityViewController = UIActivityViewController(activityItems: [message, qrCodeImage], applicationActivities: [])
            
            present(shareActivityViewController, animated: true)
        }
    }
}
