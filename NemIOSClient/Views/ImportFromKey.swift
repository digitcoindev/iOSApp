import UIKit

class ImportFromKey: UIViewController ,UIScrollViewDelegate
{
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var key: UITextField!
    @IBOutlet weak var scroll: UIScrollView!

    let dataManager : CoreDataManager = CoreDataManager()
    var showKeyboard :Bool = true
    var currentField :UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToImportFromKey
        {
            State.fromVC = SegueToImportFromKey
        }
        
        State.currentVC = SegueToImportFromKey

        password.layer.cornerRadius = 2
        repeatPassword.layer.cornerRadius = 2
        name.layer.cornerRadius = 2
        
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func validatePassword(sender: AnyObject)
    {
        if(countElements(password.text)  < 6 )
        {
            var alert :UIAlertView = UIAlertView(title: "Validation", message: "Too short password", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            password.text = ""
        }
        repeatPassword.text = ""
    }
    
    
    @IBAction func chouseTextField(sender: AnyObject)
    {
        currentField = sender as UITextField
    }
    
    @IBAction func confirm(sender: AnyObject)
    {
        var alert :UIAlertView!
        var passwordValidate :Bool = false
        
        if(password.text != "")
        {
            if(password.text == repeatPassword.text)
            {
                passwordValidate = true;
            }
            else
            {
                alert  = UIAlertView(title: "Validation", message: "Different passwords", delegate: self, cancelButtonTitle: "OK")
                
                repeatPassword.text = ""
            }
        }
        else
        {
            alert  = UIAlertView(title: "Validation", message: "Input all fields", delegate: self, cancelButtonTitle: "OK")
        }
        
        if(name.text != ""  && key.text! != "")
        {
            if(passwordValidate)
            {
                dataManager.addWallet(name.text, password: HashManager.AES256Encrypt(password.text), privateKey : key.text!)
                
                State.fromVC = SegueToImportFromKey
                State.toVC = SegueToLoginVC
                
                NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToLoginVC )
            }
        }
        else
        {
            alert  = UIAlertView(title: "Validation", message: "Input all fields", delegate: self, cancelButtonTitle: "OK")
            
        }
        if(alert != nil)
        {
            alert.show()
        }
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject)
    {
        (sender as UITextField).becomeFirstResponder()
        
        if repeatPassword != password
        {
            repeatPassword.text = ""
        }
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.1

            keyboardHeight -= self.view.frame.height - self.scroll.frame.height
            
            self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight - 10, 0)
            self.scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 15, 0)
 
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(showKeyboard)
        {
            self.scroll.contentInset = UIEdgeInsetsZero
            self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
    
}
