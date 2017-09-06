//
//  InvoiceScannerViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import AVFoundation
import SwiftyJSON
import Contacts

/// The view controller that lets the user scan an invoice.
class InvoiceScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - View Controller Properties
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }
    
    private let session = AVCaptureSession()
    
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue",
                                             attributes: [],
                                             target: nil) // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    
    var videoDeviceInput: AVCaptureDeviceInput!
    
    private let metaDataOutput = AVCaptureMetadataOutput()
    
//    /// Bool that indicates whether the QR code scanner view is already scanning.
//    fileprivate var isScanning = false
//    
//    fileprivate var cameraNotAvailable = false
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var qrCodeScannerView: QRCodeScannerView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qrCodeScannerView.session = session
        
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If audio access is denied, audio is not recorded
         during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
        
//        view.layoutIfNeeded()
//        
//        qrCodeScannerView.delegate = self
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(resumeScanning), name: Notification.Name("resumeCaptureSession"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(stopScanning), name: Notification.Name("stopCaptureSession"), object: nil)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        resumeScanning()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        
//        stopScanning()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                if #available(iOS 10.0, *) {
                                                                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                                                                } else {
                                                                    // Fallback on earlier versions
                                                                }
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async { [unowned self] in
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showTransactionSendViewController":
            
            let destinationViewController = segue.destination as! TransactionSendViewController
            let invoiceJsonData = sender as! JSON
            destinationViewController.recipientAddress = invoiceJsonData["addr"].stringValue
            destinationViewController.amount = Double(invoiceJsonData["amount"].intValue) / Double(1000000)
            destinationViewController.message = invoiceJsonData["msg"].stringValue

        default:
            return
        }
    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    // MARK: - View Controller Helper Methods
    
    // Call this on the session queue.
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            defaultVideoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    /*
                     Why are we dispatching this to the main queue?
                     Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
                     can only be manipulated on the main thread.
                     Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    
                    self.qrCodeScannerView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                    self.qrCodeScannerView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add photo output.
        if session.canAddOutput(metaDataOutput) {
            session.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    private var sessionRunningObserveContext = 0
    
    private func addObservers() {
        session.addObserver(self, forKeyPath: "running", options: .new, context: &sessionRunningObserveContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)

    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        session.removeObserver(self, forKeyPath: "running", context: &sessionRunningObserveContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sessionRunningObserveContext {
            let newValue = change?[.newKey] as AnyObject?
            guard let isSessionRunning = newValue?.boolValue else { return }


        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async { [unowned self] in
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {

                }
            }
        }
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
    fileprivate func validate(captureResult: JSON) throws -> Bool {
        
        guard captureResult != nil else { throw AccountImportValidation.valueMissing }
        guard captureResult[QRKeys.version.rawValue].intValue == Constants.qrVersion else { throw AccountImportValidation.versionNotMatching }
        guard captureResult[QRKeys.dataType.rawValue].intValue == QRType.userData.rawValue || captureResult[QRKeys.dataType.rawValue].intValue == QRType.invoice.rawValue else { throw AccountImportValidation.dataTypeNotMatching }
        
        return true
    }
    
    /**
        Shows the add contact view controller with the received
        contact information already filled in.
     
        - Parameter jsonData: The contact information as a JSON array.
     */
    fileprivate func addContact(withJsonData jsonData: JSON) {
        
        let firstName = jsonData[QRKeys.name.rawValue].stringValue
        let lastName = jsonData["surname"].stringValue
        let accountAddress = jsonData[QRKeys.address.rawValue].stringValue
        
        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName
        let contactAccountAddress = CNLabeledValue(label: "NEM", value: accountAddress as NSString)
        contact.emailAddresses = [contactAccountAddress]
        
        InvoiceManager.sharedInstance.contactToCreate = contact
        
        performSegue(withIdentifier: "showAddressBookAddContactViewController", sender: nil)
    }
    
//    /// Stops the capture session.
//    func stopScanning() {
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            if self.isScanning {
//                self.qrCodeScannerView.captureSession.stopRunning()
//            }
//        }
//    }
//    
//    /// Resumes the capture session.
//    func resumeScanning() {
//        
//        guard cameraNotAvailable == false else { return }
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            
//            if !self.isScanning {
//                self.isScanning = true
//                self.qrCodeScannerView.scanQRCode(self.qrCodeScannerView.frame.width , height: self.qrCodeScannerView.frame.height)
//            } else {
//                self.qrCodeScannerView.captureSession.startRunning()
//            }
//        }
//    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
                for item in metadataObjects {
                    if let metadataObject = item as? AVMetadataMachineReadableCodeObject , metadataObject.type == AVMetadataObjectTypeQRCode {
        
                        guard let encodedCaptureResult = metadataObject.stringValue.data(using: String.Encoding.utf8) else {
                                        return
                                    }
                            
                                    let captureResultJSON = JSON(data: encodedCaptureResult)
                            
                                    do {
                                        let _ = try validate(captureResult: captureResultJSON)
                            
                                        switch captureResultJSON[QRKeys.dataType.rawValue].intValue {
                                        case QRType.userData.rawValue:
                            
                                            print("scanned contact")
                                            let contactJsonData = captureResultJSON[QRKeys.data.rawValue]
                                            addContact(withJsonData: contactJsonData)
                            
                                        case QRType.invoice.rawValue:
                            
                                            print("scanned invoice")
                                            let invoiceJsonData = captureResultJSON[QRKeys.data.rawValue]
                                            performSegue(withIdentifier: "showTransactionSendViewController", sender: invoiceJsonData)
                                            
                                        default:
                                            throw AccountImportValidation.versionNotMatching
                                        }
                                        
                                    } catch AccountImportValidation.versionNotMatching {
                                        
                                        failedDetectingQRCode(withError: "WRONG_QR_VERSION".localized())
                                        return
                                        
                                    } catch {
                                        
                                        return
                                    }
                    }
                }
            }
    
    func failedDetectingQRCode(withError errorMessage: String) {
        
        
                let qrCodeDetectionFailureAlert: UIAlertController = UIAlertController(title: "INFO".localized(), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
                qrCodeDetectionFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
        
                DispatchQueue.main.async {
        
                    self.present(qrCodeDetectionFailureAlert, animated: true, completion: nil)
                }
            }
}

// MARK: - QR Code Scanner Delegate

//extension InvoiceScannerViewController: QRCodeScannerDelegate {
//    
//    func detectedQRCode(withCaptureResult captureResult: String) {
//        
//        guard let encodedCaptureResult = captureResult.data(using: String.Encoding.utf8) else {
//            qrCodeScannerView.captureSession.startRunning()
//            return
//        }
//        
//        let captureResultJSON = JSON(data: encodedCaptureResult)
//        
//        do {
//            let _ = try validate(captureResult: captureResultJSON)
//            
//            switch captureResultJSON[QRKeys.dataType.rawValue].intValue {
//            case QRType.userData.rawValue:
//                
//                print("scanned contact")
//                let contactJsonData = captureResultJSON[QRKeys.data.rawValue]
//                addContact(withJsonData: contactJsonData)
//                
//            case QRType.invoice.rawValue:
//                
//                print("scanned invoice")
//                let invoiceJsonData = captureResultJSON[QRKeys.data.rawValue]
//                performSegue(withIdentifier: "showTransactionSendViewController", sender: invoiceJsonData)
//                
//            default:
//                throw AccountImportValidation.versionNotMatching
//            }
//            
//        } catch AccountImportValidation.versionNotMatching {
//            
//            failedDetectingQRCode(withError: "WRONG_QR_VERSION".localized())
//            qrCodeScannerView.captureSession.startRunning()
//            return
//            
//        } catch {
//            
//            qrCodeScannerView.captureSession.startRunning()
//            return
//        }
//    }
//    
//    func failedDetectingQRCode(withError errorMessage: String) {
//        
//        cameraNotAvailable = true
//        
//        let qrCodeDetectionFailureAlert: UIAlertController = UIAlertController(title: "INFO".localized(), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
//        
//        qrCodeDetectionFailureAlert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
//        
//        DispatchQueue.main.async {
//            
//            self.present(qrCodeDetectionFailureAlert, animated: true, completion: nil)
//        }
//    }
//}
