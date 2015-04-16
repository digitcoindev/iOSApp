import UIKit
class RegistrationVC: UIViewController
{
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    let dataManager : CoreDataManager = CoreDataManager()
    var showKeyboard :Bool = true
    
    var currentField :UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        userName.layer.cornerRadius = 2
        createPassword.layer.cornerRadius = 2
        repeatPassword.layer.cornerRadius = 2
        
        if State.fromVC != SegueToRegistrationVC
        {
            State.fromVC = SegueToRegistrationVC
        }
        
        State.currentVC = SegueToRegistrationVC

        NSNotificationCenter.defaultCenter().postNotificationName("Title", object: "New Account" )

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func chouseTextField(sender: UITextField)
    {
        currentField = sender
    }


    @IBAction func closeKeyboard(sender: UITextField)
    {
        sender.becomeFirstResponder()
    }
    
    @IBAction func validatePassword(sender: AnyObject)
    {
        if(count(createPassword.text)  < 6 )
        {
            var alert :UIAlertView = UIAlertView(title: "Validation", message: "Too short password", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            createPassword.text = ""
        }
        repeatPassword.text = ""
    }
    
    @IBAction func confirmPassword(sender: AnyObject)
    {

    }
    
    @IBAction func nextBtnPressed(sender: AnyObject)
    {
        var alert :UIAlertView!
        var passwordValidate :Bool = false

        if(createPassword.text != "")
        {
            if(createPassword.text == repeatPassword.text)
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
        
        if(userName.text != "" )
        {
            if(passwordValidate)
            {
                WalletGenerator().createWallet(userName.text, password: createPassword.text)

                State.fromVC = SegueToRegistrationVC
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
}
