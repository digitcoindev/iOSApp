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
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"keyboardWillShow", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"keyboardWillHide", object:nil)
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
        //repeatPassword.text = ""
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
                switch (key.text)
                {
                case "1":
                    
                    key.text = "5ccf739d9f40f981e100492632cf729ae7940980e677551684f4f309bac5c59d"
                    
                case "2":
                    
                    key.text = "856f5bba369241ea2e171c32cb625aa975ec5c53ea0769f30a08f70f455a867e"
                    
                default:
                    
                    break
                }
                                
                dataManager.addWallet(name.text, password: HashManager.AES256Encrypt(password.text), privateKey : HashManager.AES256Encrypt(key.text!))
                
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
        
        if repeatPassword.text != password.text
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
