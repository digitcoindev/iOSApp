//
//  InvoiceScannerViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import SwiftyJSON
import Contacts

/// The view controller that lets the user scan an invoice.
class InvoiceScannerViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    /// Bool that indicates whether the QR code scanner view is already scanning.
    fileprivate var isScanning = false
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var qrCodeScannerView: QRCodeScannerView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrCodeScannerView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isScanning {
            isScanning = true
            qrCodeScannerView.scanQRCode(qrCodeScannerView.frame.width , height: qrCodeScannerView.frame.height)
        } else {
            qrCodeScannerView.captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isScanning {
            qrCodeScannerView.captureSession.stopRunning()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showTransactionSendViewController":
            
            let destinationViewController = segue.destination as! TransactionSendViewController
            
        case "showAddressBookUpdateContactViewController":
            
            let destinationViewController = segue.destination as! AddressBookUpdateContactViewController
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /**
        Validates the capture result of the QR code scan.
     
        - Parameter captureResult: The capture result of the QR code scan a JSON array/dictionary.
     
        - Throws:
        - AccountImportValidation.ValueMissing if the capture result is missing a value.
        - AccountImportValidation.VersionNotMatching if the version value of the captured QR code doesn't match with the currently supported version by the application.
        - AccountImportValidation.DataTypeNotMatching if the data type value of the captured QR code doesn't match with the account data type supported by this view controller.
     
        - Returns: A bool indicating that the validation was successful.
     */
    fileprivate func validate(captureResult: JSON) throws -> Bool {
        
        guard captureResult != nil else { throw AccountImportValidation.valueMissing }
        guard captureResult[QRKeys.Version.rawValue].intValue == QR_VERSION else { throw AccountImportValidation.versionNotMatching }
        guard captureResult[QRKeys.DataType.rawValue].intValue == QRType.userData.rawValue || captureResult[QRKeys.DataType.rawValue].intValue == QRType.invoice.rawValue else { throw AccountImportValidation.dataTypeNotMatching }
        
        return true
    }
    
    /**
        Shows the add contact view controller with the received
        contact information already filled in.
     
        - Parameter jsonData: The contact information as a JSON array.
     */
    fileprivate func addContact(withJsonData jsonData: JSON) {
        
        let firstName = jsonData[QRKeys.Name.rawValue].stringValue
        let lastName = jsonData["surname"].stringValue
        let accountAddress = jsonData[QRKeys.Address.rawValue].stringValue
        
        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName
        let contactAccountAddress = CNLabeledValue(label: "NEM", value: accountAddress as NSString)
        contact.emailAddresses = [contactAccountAddress]
        
        performSegue(withIdentifier: "showAddressBookUpdateContactViewController", sender: contact)
    }
  
    func contactAdded(_ successfuly: Bool, sendTransaction :Bool) {
        if successfuly {
//            let navDelegate = (self.delegate as? InvoiceViewController)?.delegate as? MainVCDelegate
//            if navDelegate != nil  {
//                if sendTransaction {
//                    let correspondent :Correspondent = Correspondent()
//                    
//                    for email in AddressBookViewController.newContact!.emailAddresses{
//                        if email.label == "NEM" {
//                            correspondent.address = (email.value as? String) ?? " "
//                            correspondent.name = correspondent.address.nemName()
//                        }
//                    }
//                    State.currentContact = correspondent
//                }
//                navDelegate!.pageSelected(sendTransaction ? SegueToSendTransaction : SegueToAddressBook)
//            }
        }
    }
}

// MARK: - QR Code Scanner Delegate

extension InvoiceScannerViewController: QRCodeScannerDelegate {
    
    func detectedQRCode(withCaptureResult captureResult: String) {
        
        guard let encodedCaptureResult = captureResult.data(using: String.Encoding.utf8) else {
            qrCodeScannerView.captureSession.startRunning()
            return
        }
        
        let captureResultJSON = JSON(data: encodedCaptureResult)
        
        // TODO:
        print(captureResultJSON)
        
        do {
            try validate(captureResult: captureResultJSON)
            
            switch captureResultJSON[QRKeys.DataType.rawValue].intValue {
            case QRType.userData.rawValue:
                
                print("scanned contact")
                let contactJsonData = captureResultJSON[QRKeys.Data.rawValue]
                addContact(withJsonData: contactJsonData)
                
            case QRType.invoice.rawValue:
                
                print("scanned invoice")
                let invoiceJsonData = captureResultJSON[QRKeys.Data.rawValue]
                performSegue(withIdentifier: "showTransactionSendViewController", sender: invoiceJsonData)
                
            default:
                throw AccountImportValidation.versionNotMatching
            }
            
        } catch AccountImportValidation.versionNotMatching {
            
            failedDetectingQRCode(withError: "WRONG_QR_VERSION".localized())
            qrCodeScannerView.captureSession.startRunning()
            return
            
        } catch {
            
            qrCodeScannerView.captureSession.startRunning()
            return
        }
    }
    
    func failedDetectingQRCode(withError errorMessage: String) {
        
        let qrCodeDetectionFailureAlert: UIAlertController = UIAlertController(title: "INFO".localized(), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        qrCodeDetectionFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        
        present(qrCodeDetectionFailureAlert, animated: true, completion: nil)
    }
}
