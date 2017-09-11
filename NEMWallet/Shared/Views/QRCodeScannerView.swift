//
//  QRCodeScannerView.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import AVFoundation

/**
    The view that is able to scan and detect a QR code and show a camera preview in the process. 
    Once the view detected a QR code it will show the detected qr code as an image instead of
    showing the camera preview.
 */
final class QRCodeScannerView: UIView {
    
    // MARK: - View Properties
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    // MARK: - View Lifecycle
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
