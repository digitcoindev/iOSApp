import UIKit
class RegistrationVC: AbstractViewController
{
    //MARK: - Private Variables

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Private Variables

    private var _currentField :UITextField!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        State.fromVC = SegueToRegistrationVC
        State.currentVC = SegueToRegistrationVC
        
        if State.countVC <= 1{
            backButton.hidden = true
        }
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
    
    @IBAction func chouseTextField(sender: UITextField) {
       _currentField = sender
    }
    
    @IBAction func cofigurateField(sender: UITextField) {

        validateField(sender)
    }
    

    @IBAction func changeTextField(sender: UITextField) {
        if sender == userName{
            createPassword.becomeFirstResponder()
            chouseTextField(createPassword)
        } else if createPassword == sender {
            repeatPassword.becomeFirstResponder()
            chouseTextField(repeatPassword)
        }
    }
    
    @IBAction func validateField(sender: UITextField){
        
        switch sender
        {
        case createPassword , repeatPassword:
            
            if Validate.password(createPassword.text){
                sender.textColor = UIColor.greenColor()
            } else {
                sender.textColor = UIColor.redColor()
            }
            
            if sender.text != createPassword.text{
                sender.textColor = UIColor.redColor()
            }
            
            if sender.text == "" {
                sender.textColor = UIColor.blackColor()
            }
            
        default:
            break
        }
    }
    
    @IBAction func nextBtnPressed(sender: AnyObject) {        
        var alert :UIAlertView!
        
        if createPassword.text != "" && repeatPassword.text != "" && userName.text != "" {
            if Validate.password(createPassword.text)
            {
                if(createPassword.text == repeatPassword.text)
                {
                    WalletGenerator().createWallet(userName.text, password: createPassword.text)
                    
                    State.fromVC = SegueToRegistrationVC
                    State.toVC = SegueToLoginVC
                    
                    if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                        (self.delegate as! MainVCDelegate).pageSelected(SegueToLoginVC)
                    }
                }
                else {
                    alert  = UIAlertView(title: "Validation", message: "Different passwords", delegate: self, cancelButtonTitle: "OK")
                }
            }
            else {
                alert  = UIAlertView(title: "Validation", message: "Your password must be at least 6 characters.", delegate: self, cancelButtonTitle: "OK")
            }
        }
        else {
            alert  = UIAlertView(title: "Validation", message: "Input all fields", delegate: self, cancelButtonTitle: "OK")
        }
        
        if(alert != nil) {
            alert.show()
        }
        
    }
}
