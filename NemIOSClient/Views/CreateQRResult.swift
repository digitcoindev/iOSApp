import UIKit
import Social
import MessageUI

class CreateQRResult: AbstractViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var xems: UILabel!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var mail: UIButton!
    @IBOutlet weak var invoiceNumber: UILabel!
    
    var invoice = State.invoice!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if State.fromVC != SegueToCreateQRResult {
            State.fromVC = SegueToCreateQRResult
        }
        
        State.currentVC = SegueToCreateQRResult
        
        invoiceNumber.text = "#\(invoice.number)"
        xems.text = "\(invoice.amount)" + " XEM"
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let address_Normal = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        
        address.text = address_Normal
        
        //var login = State.currentWallet!.login
        //var password = State.currentWallet!.password
       // var salt = State.currentWallet!.salt
        //let privateKey_Normal = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        //var privateKey_AES = HashManager.AES256Encrypt(privateKey_Normal, key: "my qr key")
        let objects = [invoice.name, invoice.address, invoice.amount, invoice.message]
        let keys = ["name", "address", "amount", "message"]
        
        let jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects as [AnyObject], forKeys: keys)
        let jsonDictionary :NSDictionary = NSDictionary(objects: [3, jsonAccountDictionary], forKeys: ["type", "data"])
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        let base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        let qr :QR = QR()
        
        qrImage.image =  qr.createQR(base64String)

    }
    
    override func viewDidAppear(animated: Bool) {
        self.share.imageEdgeInsets = UIEdgeInsetsMake(10, self.share.bounds.width / 2 - 20, 30, self.share.bounds.width / 2 - 20)
        self.mail.imageEdgeInsets = UIEdgeInsetsMake(10, self.mail.bounds.width / 2 - 20, 30, self.mail.bounds.width / 2 - 20)
    }

    @IBAction func shareBtn(sender: AnyObject) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {            
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Scan this QR if you want to send me \(invoice.amount) XEM\nThank you , and goodluck!")
            facebookSheet.addImage(qrImage.image!)
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
            
            let sentfrom = "Scan this QR if you want to send me \(invoice.amount) XEM\nThank you , and goodluck!"
            myMail.setMessageBody(sentfrom, isHTML: true)
            
            let image = qrImage.image!
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
