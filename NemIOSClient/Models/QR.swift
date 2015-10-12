import UIKit
import AVFoundation

@objc protocol QRDelegate
{
    func detectedQRWithString(text :String)
    optional func failedWithError(text :String)
}

class QR: UIView , AVCaptureMetadataOutputObjectsDelegate
{
    //MARK: - Local Variables

    var delegate :QRDelegate? = nil
    let previewLayer = AVCaptureVideoPreviewLayer()
    var currentresult :String!
    let session :AVCaptureSession = AVCaptureSession()
    let qrImg :UIImageView = UIImageView()
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    //MARK: - Load Methods

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MARK: - QR Methods

    final func scanQR(width :CGFloat , height :CGFloat) {
        if((device) != nil) {
            let input = try? AVCaptureDeviceInput(device: device)
            let output = AVCaptureMetadataOutput()
            let bounds:CGRect = CGRect(x: width / 2, y: height / 2, width: width, height: height)

            session.addInput(input)
            
            output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            session.addOutput(output)
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            previewLayer.session =  session
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer.bounds = bounds
            previewLayer.position = bounds.origin
            
            self.layer.addSublayer(previewLayer)
            session.startRunning()
            
            qrImg.hidden = true
            qrImg.frame = CGRect(x: 0, y:0, width: self.frame.width, height: self.frame.height)
            qrImg.contentMode = UIViewContentMode.ScaleAspectFit
            
            self.addSubview(qrImg)
        }
        else {
            let errorString = "Fail to access device camera"
            
            if self.delegate != nil {
                self.delegate!.failedWithError!(errorString)
            }
        }
    }
    
    //MARK: - QR Methods Helper

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for item in metadataObjects {
            if let metadataObject = item as? AVMetadataMachineReadableCodeObject {
                if metadataObject.type == AVMetadataObjectTypeQRCode {
                    currentresult =  metadataObject.stringValue
                    
                    qrImg.image = createQR(currentresult)
                    
                    self.stop()
                    
                    if self.delegate != nil {
                        self.delegate!.detectedQRWithString(currentresult)
                    }
                }
            }
        }
    }
    
    //MARK: - Control Methods

    final func play() {
        session.startRunning()
        qrImg.hidden = true
        previewLayer.hidden = false
    }
    
    final func stop() {
        session.stopRunning()
        previewLayer.hidden = true
        qrImg.hidden = false
    }
    
    //MARK: - QR Helper Methods
    
    final func createQR(inputStr :String) -> UIImage {
        let qrCIImage: CIImage = createQRForString(inputStr)
        let qrUIImage: UIImage = createNonInterpolatedUIImageFromCIImage(qrCIImage, scale: 10);
        
        return UIImage(CGImage: qrUIImage.CGImage!, scale: 1.0, orientation: .DownMirrored)
    }
    
    func createQRForString (qrString :NSString ) -> CIImage {
        let srtingData: NSData  = qrString.dataUsingEncoding(NSUTF8StringEncoding)!
        let qrFilter: CIFilter = CIFilter(name: "CIQRCodeGenerator")!
        
        qrFilter.setValue(srtingData, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        return qrFilter.outputImage!;
    }
    
    func createNonInterpolatedUIImageFromCIImage(image:CIImage , scale:CGFloat) -> UIImage {
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
