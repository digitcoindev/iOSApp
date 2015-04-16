import UIKit
import AVFoundation

class QR: UIView , AVCaptureMetadataOutputObjectsDelegate
{
    let previewLayer = AVCaptureVideoPreviewLayer()
    var currentresult :String!
    var session :AVCaptureSession = AVCaptureSession()
    var qrImg :UIImageView!
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    final func scanQR(width :CGFloat , height :CGFloat)
    {
        if((device) != nil)
        {
            let input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as! AVCaptureDeviceInput
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
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("Scan QR", object:"Empty scan")
            
            var alert :UIAlertView = UIAlertView(title: "Error", message: "Fail to access device camera", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        for item in metadataObjects
        {
            if let metadataObject = item as? AVMetadataMachineReadableCodeObject
            {
                if metadataObject.type == AVMetadataObjectTypeQRCode
                {
                    currentresult =  metadataObject.stringValue
                    
                    self.stop()
                    
                    qrImg = UIImageView(image: createQR(currentresult))
                    qrImg.frame = CGRect(x: 0, y:0, width: self.frame.width, height: self.frame.height)
                    qrImg.contentMode = UIViewContentMode.Center
                    
                    self.addSubview(qrImg)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("Scan QR", object:currentresult)
                    
                    previewLayer.removeFromSuperlayer()
                }
            }
        }
    }
    final func play()
    {
        session.startRunning()
    }
    
    final func stop()
    {
        session.stopRunning()
    }
    
    final func createQR(inputStr :String) -> UIImage
    {
        var qrCIImage: CIImage = createQRForString(inputStr)
        var qrUIImage: UIImage = createNonInterpolatedUIImageFromCIImage(qrCIImage, scale: 10);
        UIImage(CGImage: qrUIImage.CGImage, scale: 1.0, orientation: .DownMirrored)
        
        return UIImage(CGImage: qrUIImage.CGImage, scale: 1.0, orientation: .DownMirrored)!
    }
    
    func createQRForString (qrString :NSString ) -> CIImage
    {
        var srtingData: NSData  = qrString.dataUsingEncoding(NSUTF8StringEncoding)!
        var qrFilter: CIFilter = CIFilter(name: "CIQRCodeGenerator")
        
        qrFilter.setValue(srtingData, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        return qrFilter.outputImage;
    }
    
    func createNonInterpolatedUIImageFromCIImage(image:CIImage , scale:CGFloat) -> UIImage
    {
        var cgImage: CGImageRef = CIContext(options: nil).createCGImage(image, fromRect: image.extent())
        
        UIGraphicsBeginImageContext(CGSizeMake(image.extent().size.width * scale, image.extent().size.height * scale ))
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        
        var scaledImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
