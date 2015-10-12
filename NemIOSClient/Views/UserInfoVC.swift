import UIKit

class UserInfoVC: AbstractViewController
{
    // MARK: - @IBOutlet

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var userName: UITextField!
    
    // MARK: - Private Variables

    private var address :String!
    private var popup :AbstractViewController? = nil
    
    // MARK: - Load Metods

    override func viewDidLoad() {
        super.viewDidLoad()

        State.fromVC = SegueToUserInfo
        State.currentVC = SegueToUserInfo
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let publicKey = KeyGenerator.generatePublicKey(privateKey)
        address = AddressGenerator.generateAddress(publicKey)
        
        userAddress.text = _normalize(address)
        userName.placeholder = State.currentWallet!.login
        
        _generateQR()
    }
    
    // MARK: - @IBAction

    @IBAction func nameChanged(sender: AnyObject) {
        userName.becomeFirstResponder()
        
        _generateQR()
    }
    
    @IBAction func copyAddress(sender: AnyObject) {
        let pasteBoard :UIPasteboard = UIPasteboard.generalPasteboard()
        pasteBoard.string = address

    }
    
    @IBAction func shareAddress(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
        shareVC.delegate = self
        
        shareVC.message = userAddress.text
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })        
    }
    
    @IBAction func copyQR(sender: AnyObject) {
        let pasteBoard :UIPasteboard = UIPasteboard.generalPasteboard()
        pasteBoard.string = (Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login) + ": " + address
    }
    
    @IBAction func shareQR(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
        shareVC.delegate = self
        
        shareVC.message = (Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login) + ": " + address
        shareVC.images = [qrImageView.image!]
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
    
    private final func _normalize(text: String) -> String {
        var newString = ""
        for var i = 0 ; i < text.characters.count ; i+=4 {
            let substring = (text as NSString).substringWithRange(NSRange(location: i, length: 4))
            newString += substring + "-"
        }
        let length :Int = newString.characters.count - 1
        return (newString as NSString).substringWithRange(NSRange(location: 0, length: length))
    }
    
    private final func _generateQR()
    {
        let userDictionary: [String : String] = [
            QRKeys.Address.rawValue : address,
            QRKeys.Name.rawValue : Validate.stringNotEmpty(userName.text) ? userName.text! : State.currentWallet!.login
        ]
        
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.UserData.rawValue, userDictionary], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue])
        
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        
        let base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        let qr :QR = QR()
        qrImageView.image =  qr.createQR(base64String)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
