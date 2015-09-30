import UIKit
import Social
import MessageUI

class ExportAccountVC: UIViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if State.fromVC != SegueToExportAccount {
            State.fromVC = SegueToExportAccount
        }
        
        State.currentVC = SegueToExportAccount
        
        observer.addObserver(self, selector: "detectedQR:", name: "Scan QR", object: nil)
        
        let login = State.currentWallet!.login
        let password = State.currentWallet!.password
        let salt = State.currentWallet!.salt
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let privateKey_AES = HashManager.AES256Encrypt(privateKey, key: "my qr key")
        let objects = [login, password, salt, privateKey_AES]
        let keys = ["login", "password", "salt", "private"]
        
        let jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects, forKeys: keys)
        let jsonDictionary :NSDictionary = NSDictionary(objects: [3, jsonAccountDictionary], forKeys: ["type", "data"])
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        let base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        let qr :QR = QR()
        
        qrImage.image =  qr.createQR(base64String)
    }
    
    @IBAction func mailBtn(sender: AnyObject) {
        if(MFMailComposeViewController.canSendMail()){
            let myMail : MFMailComposeViewController = MFMailComposeViewController()
            
            myMail.mailComposeDelegate = self
            
            myMail.setSubject("NEM")
            
            let sentfrom = "Scan this QR if you want to import : \"\(State.currentWallet!.login)\" account."
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
