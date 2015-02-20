import UIKit
import Social
import MessageUI

class CreateQRResult: UIViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var xems: UILabel!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToCreateQRResult
        {
            State.fromVC = SegueToCreateQRResult
        }
        
        State.currentVC = SegueToCreateQRResult
        
        xems.text = "\(State.amount)" + " XEM"
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var publicKey = KeyGenerator().generatePublicKey(privateKey)
        
        address.text = publicKey as String
        
        var qr :QR = QR()
        var qrText :String = "{\"address\":\"\(address.text!)\",\"amount\":\"\(State.amount)\"}"
        
        qrImage.image =  qr.createQR(qrText)

    }

    @IBAction func shareBtn(sender: AnyObject)
    {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
        {
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Scan this QR if you want to sand me \(State.amount) XEMS\nThank you , and goodluck!")
            facebookSheet.addImage(qrImage.image!)
            self.presentViewController(facebookSheet, animated: true, completion: nil)
            
        }
        else
        {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func mailBtn(sender: AnyObject)
    {
        if(MFMailComposeViewController.canSendMail()){
            var myMail : MFMailComposeViewController = MFMailComposeViewController()
            
            myMail.mailComposeDelegate = self
            
            myMail.setSubject("NEM")
            
//            var toRecipients = ["dominik2008@ua.fm"]
//            myMail.setToRecipients(toRecipients)
            
//            var ccRecipients = ["dominik2008@i.ua"]
//            myMail.setCcRecipients(ccRecipients)
            
            var sentfrom = "Scan this QR if you want to sand me \(State.amount) XEMS\nThank you , and goodluck!"
            myMail.setMessageBody(sentfrom, isHTML: true)
            
            var image = qrImage.image!
            var imageData = UIImageJPEGRepresentation(image, 1.0)
            
            myMail.addAttachmentData(imageData, mimeType: "image/jped", fileName: "image")
            
            //Display the view controller
            self.presentViewController(myMail, animated: true, completion: nil)
        }
        else
        {
            var alert :UIAlertView = UIAlertView(title: "Info", message: "Your device can not send emails", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        var alert :UIAlertView = UIAlertView(title: "Info", message: "Currently unavailable.\nIn developing process. ", delegate: self, cancelButtonTitle: "OK")
        alert.show()
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}
