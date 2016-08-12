//
//  QRCodeScannerView.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import AVFoundation

// MARK: - QR Code Scanner Delegate Protocol

protocol QRCodeScannerDelegate {
    func detectedQRCode(withCaptureResult captureResult: String)
    func failedDetectingQRCode(withError errorMessage: String)
}

/**
    The view that is able to scan and detect a QR code and show a
    camera preview in the process. Once the view detected a QR code
    the view will show the detected qr code as an image instead of
    showing the camera preview.
 */
class QRCodeScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - View Properties

    var delegate: QRCodeScannerDelegate?
    
    let captureSession :AVCaptureSession = AVCaptureSession()
    let capturePreviewLayer = AVCaptureVideoPreviewLayer()
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var captureResult = String()

    // MARK: - View Helper Methods
    
    /**
        Starts scanning for a QR code. Shows the camera preview
        in this view while scanning. Once a QR code was detected 
        the delegate method captureOutput will get called.
     
        - Parameter width: The width of the qr scanner view.
        - Parameter height: The height of the qr scanner view.
     */
    func scanQRCode(width: CGFloat, height: CGFloat) {
        
        guard device != nil else {
            let errorMessage = "Failed to access device camera"
            delegate?.failedDetectingQRCode(withError: errorMessage)
            return
        }
        
        let captureInput = try? AVCaptureDeviceInput(device: device)
        let captureOutput = AVCaptureMetadataOutput()
        
        guard captureInput != nil else {
            let errorMessage = "Failed to access device camera"
            delegate?.failedDetectingQRCode(withError: errorMessage)
            return
        }
        
        captureSession.addInput(captureInput)
        captureOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureSession.addOutput(captureOutput)
        captureOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        let bounds: CGRect = CGRect(x: width / 2, y: height / 2, width: width, height: height)
        capturePreviewLayer.session = captureSession
        capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        capturePreviewLayer.bounds = bounds
        capturePreviewLayer.position = bounds.origin
        layer.addSublayer(capturePreviewLayer)
        
        captureSession.startRunning()
    }
    
    /**
        This delegate method will get called once a QR code got 
        detected.
     */
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        for item in metadataObjects {
            if let metadataObject = item as? AVMetadataMachineReadableCodeObject where metadataObject.type == AVMetadataObjectTypeQRCode {
                
                captureResult = metadataObject.stringValue
                captureSession.stopRunning()
                
                delegate?.detectedQRCode(withCaptureResult: captureResult)
            }
        }
    }
    
    /**
        Creates an image from the captured QR code.
     
        - Parameter captureResult: The capture result from the scanned QR code that should get turned into an image.
     
        - Returns: The scanned QR code as an image.
     */
    func createQRCodeImage(fromCaptureResult captureResult: String) -> UIImage {
        
        let qrCodeCIImage: CIImage = createQRCodeCIImage(fromCaptureResult: captureResult)
        let qrCodeUIImage: UIImage = createNonInterpolatedUIImage(fromCIImage: qrCodeCIImage, scale: 10)
        
        return UIImage(CGImage: qrCodeUIImage.CGImage!, scale: 1.0, orientation: .DownMirrored)
    }
    
    /**
        Creates a CI image from the captured QR code.
     
        - Parameter captureResult: The capture result from the scanned QR code that should get turned into a CI image.
     
        - Returns: The scanned QR code as a CI image.
     */
    private func createQRCodeCIImage(fromCaptureResult captureResult: NSString) -> CIImage {
        
        let stringData: NSData = captureResult.dataUsingEncoding(NSUTF8StringEncoding)!
        let qrCodeFilter: CIFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrCodeFilter.setValue(stringData, forKey: "inputMessage")
        qrCodeFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        return qrCodeFilter.outputImage!
    }
    
    /**
        Creates a UI image from a provided CI image.
     
        - Parameter image: The CI image that should get converted into a UI image.
        - Parameter scale: The scale of the new UI image.
     
        - Returns: The converted UI image.
     */
    private func createNonInterpolatedUIImage(fromCIImage image: CIImage, scale: CGFloat) -> UIImage {
        
        let cgImage: CGImageRef = CIContext(options: nil).createCGImage(image, fromRect: image.extent)
        
        UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.height * scale ))
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.None)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        
        let scaledImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
