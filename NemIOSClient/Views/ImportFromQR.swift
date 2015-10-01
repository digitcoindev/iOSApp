import UIKit

class ImportFromQR: AbstractViewController, QRDelegate
{
    //MARK: - IBOulets

    @IBOutlet weak var screenScaner: QR!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToImportFromQR
        State.currentVC = SegueToImportFromQR

        screenScaner.delegate = self
        
        let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        if State.countVC <= 1{
            backButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        screenScaner.scanQR(screenScaner.frame.width , height: screenScaner.frame.height )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    //MARK: - QRDelegate Methods
    
    func detectedQRWithString(text: String) {
        let base64String :String = text
        let jsonData :NSData = NSData(base64EncodedString: base64String)
        var jsonStructure :NSDictionary? = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves)) as? NSDictionary

        if jsonStructure == nil {
            screenScaner.play()
        }
        else if jsonStructure!.objectForKey("type") as! Int == 3 {
            jsonStructure = jsonStructure!.objectForKey("data") as? NSDictionary
            
            if jsonStructure != nil {
                let privateKey_AES = jsonStructure!.objectForKey("private") as! String
                let privateKey = HashManager.AES256Decrypt(privateKey_AES, key: "my qr key")
                let privateKey_Encrypted = HashManager.AES256Encrypt(privateKey)
                let login = jsonStructure!.objectForKey("login") as! String
                let password = jsonStructure!.objectForKey("password") as! String
                let salt = jsonStructure!.objectForKey("salt") as! String
                
                WalletGenerator().importWallet(login, password: password, privateKey: privateKey_Encrypted ,salt: salt)
                let alert :UIAlertController = UIAlertController(   title: NSLocalizedString("INFO", comment: "Title"),
                                                                    message: String(format: NSLocalizedString("ACCOUNT_ADDING_SUCCESS", comment: "Description"), login),
                                                                    preferredStyle: UIAlertControllerStyle.Alert)
                
                let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                    {
                        alertAction -> Void in
                        
                        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                            (self.delegate as! MainVCDelegate).pageSelected(SegueToLoginVC)
                        }
                    }
                
                alert.addAction(ok)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            screenScaner.play()
        }
    }
}
