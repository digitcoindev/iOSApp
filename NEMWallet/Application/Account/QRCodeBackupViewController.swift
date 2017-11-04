//
//  QRCodeBackupViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class QRCodeBackupViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var backupJSONString: String?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var backupQRCodeImageView: UIImageView!
    @IBOutlet weak var saveBackupQRCodeButton: UIButton!
    @IBOutlet weak var verifyBackupButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateAppearance()
        
        informationLabel.text = "Store this backup QR code as well as the password you've chosen in the previous step in a safe place - you'll then be able to import that account into any NEM client again by scanning the QR code and providing the password you have chosen"
        
        generateQRCode(forAccount: backupJSONString!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showVerifyQRCodeBackupViewController":
            
            let destinationViewController = segue.destination as! VerifyQRCodeBackupViewController
            destinationViewController.account = account
            
        default:
            break
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /**
        Generates the QR code image for the account export.
     
        - Parameter accountJsonString: The account export json string for which the QR code should get generated.
     */
    fileprivate func generateQRCode(forAccount accountJsonString: String) {
        
        backupQRCodeImageView.image = accountJsonString.createQRCodeImage()
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        saveBackupQRCodeButton.layer.cornerRadius = 10.0
        verifyBackupButton.layer.cornerRadius = 10.0
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func saveBackupQRCode(_ sender: UIButton) {
        
        if let qrCodeImage = backupQRCodeImageView.image {
            
            let shareActivityViewController = UIActivityViewController(activityItems: [qrCodeImage], applicationActivities: [])
            present(shareActivityViewController, animated: true)
        }
    }
}
