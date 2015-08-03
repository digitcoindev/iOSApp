import UIKit

class ImportFromQR: AbstractViewController
{
    @IBOutlet weak var screenScaner: QR!
    
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToImportFromQR
        {
            State.fromVC = SegueToImportFromQR
        }
        
        State.currentVC = SegueToImportFromQR

        observer.addObserver(self, selector: "detectedQR:", name: "Scan QR", object: nil)
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        observer.postNotificationName("Title", object:"Scan your account" )

        screenScaner.scanQR(screenScaner.frame.width , height: screenScaner.frame.height )
    }
    
    func detectedQR(notification: NSNotification)
    {
        var base64String :String = notification.object as! String
        var jsonData :NSData = NSData(base64EncodedString: base64String)
        var err: NSError?
        var jsonStructure :NSDictionary? = NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableLeaves, error: &err) as? NSDictionary
        

        if err != nil || jsonStructure == nil
        {
            screenScaner.play()
        }
        else if jsonStructure!.objectForKey("type") as! Int == 3
        {
            jsonStructure = jsonStructure!.objectForKey("data") as? NSDictionary
            
            if jsonStructure != nil
            {
                var privateKey_AES = jsonStructure!.objectForKey("private") as! String
                var privateKey = HashManager.AES256Decrypt(privateKey_AES, key: "my qr key")
                var privateKey_Encrypted = HashManager.AES256Encrypt(privateKey)
                var login = jsonStructure!.objectForKey("login") as! String
                var password = jsonStructure!.objectForKey("password") as! String
                var salt = jsonStructure!.objectForKey("salt") as! String
                
                WalletGenerator().importWallet(login, password: password, privateKey: privateKey_Encrypted ,salt: salt)
                var alert :UIAlertController = UIAlertController(title: "Info", message: "Account: \(login)\nSuccessfully added.", preferredStyle: UIAlertControllerStyle.Alert)
                
                var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                    {
                        alertAction -> Void in
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToLoginVC )
                    }
                
                alert.addAction(ok)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else
        {
            screenScaner.play()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
