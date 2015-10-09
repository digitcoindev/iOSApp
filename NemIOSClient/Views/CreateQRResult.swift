import UIKit
import Social
import MessageUI

class CreateQRResult: AbstractViewController , MFMailComposeViewControllerDelegate
{
    // MARK: - @IBOutlet
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Private Variables
    
    private var invoice = State.invoice
    
    // MARK: - Load Metods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToCreateInvoiceResult
        State.currentVC = SegueToCreateInvoiceResult
        
        if invoice != nil {
            _generateQR()
            State.invoice = nil
            
            var titleText :NSMutableAttributedString = NSMutableAttributedString(string: "NAME: " , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 10)!])
            var contentText :NSMutableAttributedString = NSMutableAttributedString(string: invoice!.name , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 20)!])
            
            titleText.appendAttributedString(contentText)
            nameLabel.attributedText = titleText
            
            titleText = NSMutableAttributedString(string: "AMOUNT: " , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 10)!])
            contentText = NSMutableAttributedString(string: "\(invoice!.amount) XEM" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 20)!])
            
            titleText.appendAttributedString(contentText)
            amountLabel.attributedText = titleText
            
            titleText = NSMutableAttributedString(string: "MESSAGE: " , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 10)!])
            contentText = NSMutableAttributedString(string: invoice!.message , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 20)!])
            
            titleText.appendAttributedString(contentText)
            messageLabel.attributedText = titleText
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    // MARK: - @IBAction
    
    @IBAction func copyQR(sender: AnyObject) {
        var copyString :String = ""
        
        if invoice != nil {
            copyString += "Name: \(invoice!.name) \n"
            copyString += "Address: \(invoice!.address) \n"
            copyString += "Amount: \(invoice!.amount) \n"
            copyString += "Message: \(invoice!.message) \n"
        } else {
            copyString += "Empty QR"
        }
        
        let pasteBoard :UIPasteboard = UIPasteboard.generalPasteboard()
        pasteBoard.string = copyString
    }
    
    @IBAction func shareQR(sender: AnyObject) {
        
    }
    
    @IBAction func shareBtn(sender: AnyObject) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Scan this QR if you want to send me \(invoice!.amount) XEM\nThank you , and goodluck!")
            facebookSheet.addImage(qrImageView.image!)
            self.presentViewController(facebookSheet, animated: true, completion: nil)
            
        }
        else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func mailBtn(sender: AnyObject) {
        if(MFMailComposeViewController.canSendMail()){
            let myMail : MFMailComposeViewController = MFMailComposeViewController()
            
            myMail.mailComposeDelegate = self
            
            myMail.setSubject("NEM")
            
            let sentfrom = "Scan this QR if you want to send me \(invoice!.amount) XEM\nThank you , and goodluck!"
            myMail.setMessageBody(sentfrom, isHTML: true)
            
            let image = qrImageView.image!
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            
            myMail.addAttachmentData(imageData!, mimeType: "image/jped", fileName: "image")
            
            //Display the view controller
            self.presentViewController(myMail, animated: true, completion: nil)
        }
        else {
            let alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: "Your device can not send emails", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    // MARK: -  Private Helpers
    
    private final func _generateQR()
    {
        let userDictionary: [String : AnyObject] = [
            QRKeys.Address.rawValue : invoice!.address,
            QRKeys.Name.rawValue : invoice!.name,
            QRKeys.Amount.rawValue : invoice!.amount,
            QRKeys.Message.rawValue : invoice!.message
        ]
        
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.Invoice.rawValue, userDictionary], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue])
        
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        
        let base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        let qr :QR = QR()
        
        qrImageView.image =  qr.createQR(base64String)
    }
    
    // MARK: -  MFMailComposeViewControllerDelegate Methos
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
