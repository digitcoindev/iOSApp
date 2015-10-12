import UIKit
import Social
import MessageUI

class CreateQRResult: AbstractViewController, MFMailComposeViewControllerDelegate
{
    // MARK: - @IBOutlet
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Private Variables
    
    private var invoice = State.invoice
    private var popup :AbstractViewController? = nil

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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
        shareVC.delegate = self
        
        shareVC.message = NSLocalizedString("INVOICE_HEADER", comment: "Message")
        shareVC.images = [qrImageView.image!]
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
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
