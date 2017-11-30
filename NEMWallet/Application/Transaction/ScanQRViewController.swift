//
//  ScanQRViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import AVFoundation
import SwiftyJSON

///
final class ScanQRViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    private var setupResult: SessionSetupResult = .success
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var metaDataOutput = AVCaptureMetadataOutput()
    
    ///
    private var captureResult: JSON?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var qrScannerView: QRScannerView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationLabel.text = "Pay an invoice by scanning the corresponding invoice QR code, or select a recipient address by scanning an account details QR code"
        
        qrScannerView.session = session
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            break
            
        case .notDetermined:
            
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            setupResult = .notAuthorized
        }
        
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                
                DispatchQueue.main.async { [unowned self] in
                    let alertController = UIAlertController(title: "Warning", message: "NEM Wallet doesn't have permission to use the camera, please change privacy settings", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { _ in
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                        }
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                
                DispatchQueue.main.async { [unowned self] in
                    let alertController = UIAlertController(title: "Error", message: "Something went wrong when accessing the device camera", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        sessionQueue.async { [weak self] in
            if self?.setupResult == .success {
                self?.session.stopRunning()
                self?.isSessionRunning = false
                self?.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "unwindToCreateTransactionViewController":
            
            let destinationViewController = segue.destination as! CreateTransactionViewController
            destinationViewController.qrCaptureResult = captureResult
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    ///
    private func configureSession() {
        
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            defaultVideoDevice = AVCaptureDevice.default(for: AVMediaType.video)
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    let initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    self.qrScannerView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                    self.qrScannerView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
        
        // Add meta data output.
        if session.canAddOutput(metaDataOutput) {
            session.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
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
}

extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Capture Output Delegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for item in metadataObjects {
            if let metadataObject = item as? AVMetadataMachineReadableCodeObject , metadataObject.type == AVMetadataObject.ObjectType.qr {
                
                guard let encodedCaptureResult = metadataObject.stringValue?.data(using: String.Encoding.utf8) else {
                    return
                }
                
                let captureResultJSON = JSON(data: encodedCaptureResult)
                
                do {
                    let _ = try validate(captureResult: captureResultJSON)
                    
                    captureResult = captureResultJSON
                    performSegue(withIdentifier: "unwindToCreateTransactionViewController", sender: nil)
                    
                } catch AccountImportValidation.versionNotMatching {
                    
                    failedDetectingQRCode(withError: "WRONG_QR_VERSION".localized())
                    return
                    
                } catch AccountImportValidation.dataTypeNotMatching {
                    
                    failedDetectingQRCode(withError: "Wrong QR code type")
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
