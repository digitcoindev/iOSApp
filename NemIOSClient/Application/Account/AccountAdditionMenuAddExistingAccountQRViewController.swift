//
//  AccountAdditionMenuAddExistingAccountQRViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import SwiftyJSON

/**
    The account addition view controller that lets the user add an existing
    account through scanning the qr code for the account.
 */
class AccountAdditionMenuAddExistingAccountQRViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    /// Bool that indicates whether the QR code scanner view is already scanning.
    private var isScanning = false
    
    /// The title of the account that should get imported.
    private var accountTitle = String()
    
    /// The encrypted private key of the account that should get imported.
    private var accountEncryptedPrivateKey = String()
    
    /// The salt of the account that should get imported.
    private var accountSalt = String()
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var qrCodeScannerView: QRCodeScannerView!

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    
        updateViewControllerAppearance()
        
        qrCodeScannerView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isScanning {
            isScanning = true
            qrCodeScannerView.scanQRCode(qrCodeScannerView.frame.width , height: qrCodeScannerView.frame.height)
        } else {
            qrCodeScannerView.captureSession.startRunning()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "showAccountAdditionMenuPasswordValidationViewController":
            
            let destinationViewController = segue.destinationViewController as! AccountAdditionMenuPasswordValidationViewController
            destinationViewController.accountTitle = accountTitle
            destinationViewController.accountEncryptedPrivateKey = accountEncryptedPrivateKey
            destinationViewController.accountSalt = accountSalt
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        title = "SCAN_QR_CODE".localized()
    }
    
    /**
        Validates the capture result of the QR code scan.
     
        - Parameter captureResult: The capture result of the QR code scan a JSON array/dictionary.
     
        - Throws:
            - AccountImportValidation.ValueMissing if the capture result is missing a value.
            - AccountImportValidation.VersionNotMatching if the version value of the captured QR code doesn't match with the currently supported version by the application.
            - AccountImportValidation.DataTypeNotMatching if the data type value of the captured QR code doesn't match with the account data type supported by this view controller.
     
        - Returns: A bool indicating that the validation was successful.
     */
    private func validate(captureResult captureResult: JSON) throws -> Bool {
        
        guard captureResult != nil else { throw AccountImportValidation.ValueMissing }
        guard captureResult[QRKeys.Version.rawValue].intValue == QR_VERSION else { throw AccountImportValidation.VersionNotMatching }
        guard captureResult[QRKeys.DataType.rawValue].intValue == QRType.AccountData.rawValue else { throw AccountImportValidation.DataTypeNotMatching }
        guard captureResult["data"][QRKeys.Name.rawValue].string != nil else { throw AccountImportValidation.ValueMissing }
        guard captureResult["data"][QRKeys.PrivateKey.rawValue].string != nil else { throw AccountImportValidation.ValueMissing }
        guard captureResult["data"][QRKeys.Salt.rawValue].string != nil else { throw AccountImportValidation.ValueMissing }
        
        return true
    }
}

// MARK: - QR Code Scanner Delegate

extension AccountAdditionMenuAddExistingAccountQRViewController: QRCodeScannerDelegate {
    
    func detectedQRCode(withCaptureResult captureResult: String) {
        
        guard let encodedCaptureResult = captureResult.dataUsingEncoding(NSUTF8StringEncoding) else {
            qrCodeScannerView.captureSession.startRunning()
            return
        }
                
        let captureResultJSON = JSON(data: encodedCaptureResult)
        
        // TODO:
        print(captureResultJSON)
        
        do {
            try validate(captureResult: captureResultJSON)
            
        } catch AccountImportValidation.VersionNotMatching {
            
            failedDetectingQRCode(withError: "WRONG_QR_VERSION".localized())
            qrCodeScannerView.captureSession.startRunning()
            return
            
        } catch {
            
            qrCodeScannerView.captureSession.startRunning()
            return
        }
        
        self.accountTitle = captureResultJSON["data"][QRKeys.Name.rawValue].string!
        self.accountEncryptedPrivateKey = captureResultJSON["data"][QRKeys.PrivateKey.rawValue].string!
        self.accountSalt = captureResultJSON["data"][QRKeys.Salt.rawValue].string!
        
        performSegueWithIdentifier("showAccountAdditionMenuPasswordValidationViewController", sender: nil)
    }
    
    func failedDetectingQRCode(withError errorMessage: String) {
        
        let qrCodeDetectionFailureAlert: UIAlertController = UIAlertController(title: "INFO".localized(), message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        qrCodeDetectionFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: nil))
        
        presentViewController(qrCodeDetectionFailureAlert, animated: true, completion: nil)
    }
}
