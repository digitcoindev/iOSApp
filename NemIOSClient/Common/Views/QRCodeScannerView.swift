//
//  QRCodeScannerView.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import AVFoundation

protocol QRCodeScannerDelegate {
    func detectedQRCode(withString string: String)
    func failedWithError(error: String)
}

class QRCodeScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - View Properties

    var delegate: QRCodeScannerDelegate?
    
    let captureSession :AVCaptureSession = AVCaptureSession()
    let capturePreviewLayer = AVCaptureVideoPreviewLayer()
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    let qrCodeImageView = UIImageView()
    var captureResult = String()

    // MARK: - View Helper Methods
    
    func scanQRCode(width: CGFloat, height: CGFloat) {
        
        guard device != nil else {
            let error = "Failed to access device camera"
            delegate?.failedWithError(error)
            return
        }
        
        let captureInput = try? AVCaptureDeviceInput(device: device)
        let captureOutput = AVCaptureMetadataOutput()
        let bounds: CGRect = CGRect(x: width / 2, y: height / 2, width: width, height: height)
        
        guard captureInput != nil else {
            let error = "Failed to access device camera"
            delegate?.failedWithError(error)
            return
        }
        
        captureSession.addInput(captureInput)
        captureOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureSession.addOutput(captureOutput)
        captureOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        capturePreviewLayer.session = captureSession
        capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        capturePreviewLayer.bounds = bounds
        capturePreviewLayer.position = bounds.origin
        layer.addSublayer(capturePreviewLayer)
        
        captureSession.startRunning()
        
        qrCodeImageView.hidden = true
        qrCodeImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        qrCodeImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        addSubview(qrCodeImageView)
    }
    
    /**
 
     */
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        for item in metadataObjects {
            if let metadataObject = item as? AVMetadataMachineReadableCodeObject where metadataObject.type == AVMetadataObjectTypeQRCode {
                
                captureResult = metadataObject.stringValue
                qrCodeImageView.image = createQRCodeImage(captureResult)
                
                stop()
                delegate?.detectedQRCode(withString: captureResult)
            }
        }
    }
    
    /**
 
     */
    func play() {
        captureSession.startRunning()
        qrCodeImageView.hidden = true
        capturePreviewLayer.hidden = false
    }
    
    /**
 
     */
    func stop() {
        captureSession.stopRunning()
        capturePreviewLayer.hidden = true
        qrCodeImageView.hidden = false
    }
    
    /**
 
     */
    func createQRCodeImage(inputString: String) -> UIImage {
        
        let qrCodeCIImage: CIImage = createQRCodeCIImage(forString: inputString)
        let qrCodeUIImage: UIImage = createNonInterpolatedUIImage(fromCIImage: qrCodeCIImage, scale: 10)
        
        return UIImage(CGImage: qrCodeUIImage.CGImage!, scale: 1.0, orientation: .DownMirrored)
    }
    
    /**
 
     */
    func createQRCodeCIImage(forString qrCodeString: NSString) -> CIImage {
        
        let stringData: NSData = qrCodeString.dataUsingEncoding(NSUTF8StringEncoding)!
        let qrCodeFilter: CIFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrCodeFilter.setValue(stringData, forKey: "inputMessage")
        qrCodeFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        return qrCodeFilter.outputImage!
    }
    
    /**
 
     */
    func createNonInterpolatedUIImage(fromCIImage image: CIImage, scale: CGFloat) -> UIImage {
        
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
