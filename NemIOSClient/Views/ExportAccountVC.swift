import UIKit
import Social
import MessageUI

class ExportAccountVC: AbstractViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var privateKey: UILabel!
    @IBOutlet weak var publicKey: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var privateKeyLabel: UILabel!
    @IBOutlet weak var publicKeyLabel: UILabel!
    
    private var popup :AbstractViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToExportAccount
        State.currentVC = SegueToExportAccount
        
        let login = State.currentWallet!.login
        
        let salt = State.currentWallet!.salt
        let privateKey_AES = State.currentWallet!.privateKey
        let objects = [login, salt, privateKey_AES]
        let keys = [QRKeys.Name.rawValue, QRKeys.Salt.rawValue, QRKeys.PrivateKey.rawValue]
        
        let jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects, forKeys: keys)
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.AccountData.rawValue, jsonAccountDictionary], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue])
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        let jsonString :String = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
        let qr :QR = QR()
        
        qrImage.image =  qr.createQR(jsonString)
        
        let priv_key = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.currentWallet!.password)
        let pub_key = KeyGenerator.generatePublicKey(priv_key!)
        privateKey.text = priv_key
        publicKey.text = pub_key
        
        shareButton.setTitle("SHARE_QR".localized(), forState: UIControlState.Normal)
        titleLabel.text = "EXPORT_ACCOUNT".localized()
        publicKeyLabel.text = "PUBLIC_KEY".localized()
        publicKeyLabel.text = "PRIVATE_KEY".localized()
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    @IBAction func shareQR(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
        shareVC.delegate = self
        
        shareVC.images = [qrImage.image!]
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
}
