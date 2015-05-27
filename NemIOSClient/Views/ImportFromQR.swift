import UIKit

class ImportFromQR: UIViewController
{
    @IBOutlet weak var screenScaner: QR!
    @IBOutlet weak var addB: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var accountData :String!
    var showKeyboard :Bool = true
    var currentField :UITextField!
    
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

        addB.enabled = false

        screenScaner.scanQR(screenScaner.frame.width , height: screenScaner.frame.height )
    }
    
    func detectedQR(notification: NSNotification)
    {
        accountData = notification.object as! String
        
        addB.enabled = true
    }
    
    
    @IBAction func addAccount(sender: AnyObject)
    {
        if password.text! != "" && name.text! != ""
        {
            if Validate.password(password.text)
            {
            var dataManager :CoreDataManager = CoreDataManager()
        
            dataManager.addWallet(name.text!, password: HashManager.AES256Encrypt(password.text!) , privateKey : name.text)
        
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
            }
            else
            {
                var alert :UIAlertView = UIAlertView(title: "Info", message: "Your password must be at least 6 characters.", delegate: self, cancelButtonTitle: "OK")
            }
        }
        else
        {
            var alert :UIAlertView = UIAlertView(title: "Info", message: "Input all fields!", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
        }
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject)
    {
        (sender as! UITextField).becomeFirstResponder()
    }
    
    @IBAction func chouseTextField(sender: AnyObject)
    {
        currentField = sender as! UITextField
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.1
            
            if (keyboardHeight > (currentField.frame.origin.y - 5))
            {
                keyboardHeight = (currentField.frame.origin.y - 5 )as CGFloat
            }
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, -keyboardHeight , self.view.bounds.width, self.view.bounds.height)
                }, completion: nil)
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
            
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
                    
                }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
