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
        center.postNotificationName("Title", object:"Import from key" )

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
    
    @IBAction func returnFirstResponder(sender: AnyObject)
    {
        (sender as! UITextField).becomeFirstResponder()
    }
    
    @IBAction func chouseTextField(sender: AnyObject)
    {
        currentField = sender as! UITextField
    }
    
    @IBAction func confirm(sender: AnyObject)
    {
        var alert :UIAlertView!
        if name.text != ""  && key.text! != "" && repeatPassword.text != "" && password.text != ""
        {
            if password.text == repeatPassword.text && Validate.password(password.text)
            {
                var keyValide :Bool = true
                switch (key.text)
                {
                case "1":
                    
                    key.text = "5ccf739d9f40f981e100492632cf729ae7940980e677551684f4f309bac5c59d"
                    
                case "2":
                    
                    key.text = "168fd919078c8a2fb04183c6214ca80e9aed8ebd2fe1dd283f12cab869678bfd"
                    
                case "3":
                    
                    key.text = "6ffa04f529d52354fe139172d0529d9710065ff0ecaba60bf2233ad06731c1ba"
                    
                case "4":
                    
                    key.text = "0560458ac2789c5998f576f8eced7cc0c6d1aa74006993ead764dc0a7456db8b"
                    
                case "5":
                    
                    key.text = "05a4f584cfcd87165e2db6d1e960f331541114dcf18e557228bb288983e34ca9"
                    
                case "6":
                    
                    key.text = "3faca9b879b728bd3763bc35d3c288086f19427057c148e56f3c6f0c0237eee2"
                    
                case "7":
                    
                    key.text = "97a062d646085bb1e0f00836999cdb2ec211b594eb61a182878f5e359e0323f6"
                    
                case "8":
                    
                    key.text = "9eb58e385e2db820938a03eb226ee6a6ca7b0f8fee91596b2df377fcacd56b45"
                    
                case "9":
                    
                    key.text = "afa9f13089ce637d2cc32411b69f48c1d69ffaf28ee5b0f2b3441c4fc3a33a64"
                    
                default:
                    
                    keyValide = Validate.key(key.text)
                }
                
                if keyValide
                {
                    WalletGenerator().createWallet(name.text, password: password.text, privateKey: key.text)
                    
                    State.fromVC = SegueToImportFromKey
                    State.toVC = SegueToLoginVC
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToLoginVC )
                }
                else
                {
                    alert  = UIAlertView(title: "Validation", message: "Invalide private key.\nPlease check it.", delegate: self, cancelButtonTitle: "OK")
                }
            }
            else if !Validate.password(password.text)
            {
                alert  = UIAlertView(title: "Validation", message: "Your password must be at least 6 characters.", delegate: self, cancelButtonTitle: "OK")
                
                repeatPassword.text = ""
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
        
        if(alert != nil)
        {
            alert.show()
        }
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject)
    {
        //(sender as! UITextField).becomeFirstResponder()
        
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
            var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
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
