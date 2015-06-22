import UIKit
import Social
import MessageUI

class ExportAccountVC: UIViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToExportAccount
        {
            State.fromVC = SegueToExportAccount
        }
        
        State.currentVC = SegueToExportAccount
        
        observer.addObserver(self, selector: "detectedQR:", name: "Scan QR", object: nil)
        
        var login = State.currentWallet!.login
        var password = State.currentWallet!.password
        var salt = State.currentWallet!.salt
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var privateKey_AES = HashManager.AES256Encrypt(privateKey, key: "my qr key")
        var objects = [login, password, salt, privateKey_AES]
        var keys = ["login", "password", "salt", "private"]
        
        var jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects, forKeys: keys)
        var jsonDictionary :NSDictionary = NSDictionary(objects: [3, jsonAccountDictionary], forKeys: ["type", "data"])
        var jsonData :NSData = NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions.allZeros, error: nil)!
        var base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        
        var qr :QR = QR()
        
        qrImage.image =  qr.createQR(base64String)
    }
    
    @IBAction func mailBtn(sender: AnyObject)
    {
        if(MFMailComposeViewController.canSendMail()){
            var myMail : MFMailComposeViewController = MFMailComposeViewController()
            
            myMail.mailComposeDelegate = self
            
            myMail.setSubject("NEM")
            
            var sentfrom = "Scan this QR if you want to import : \"\(State.currentWallet!.login)\" account."
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
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
