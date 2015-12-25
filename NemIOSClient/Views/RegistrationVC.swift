import UIKit
class RegistrationVC: AbstractViewController
{
    //MARK: - Private Variables

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backButton: UIButton!
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        State.fromVC = SegueToRegistrationVC
        State.currentVC = SegueToRegistrationVC
        
        if State.countVC <= 1 {
            backButton.hidden = true
        }
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        createButton.setTitle("CREATE_NEW_ACCCOUNT".localized(), forState: UIControlState.Normal)
        titleLabel.text = "CREATE_NEW_ACCCOUNT".localized()
        userName.placeholder = "ACCOUNT_NAME_PLACEHOLDER".localized()
        createPassword.placeholder = "ENTET_PASSWORD".localized()
        repeatPassword.placeholder = "REPEAT_PASSWORD".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction

    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddAccountVC)
        }
    }
    
    @IBAction func chouseTextField(sender: UITextField) {
        scroll.scrollRectToVisible(self.view.convertRect(sender.frame, fromView: sender), animated: true)
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
        
        switch sender {
        case createPassword , repeatPassword:
            
            if Validate.password(createPassword.text!){
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
            if Validate.password(createPassword.text!) {
                if(createPassword.text == repeatPassword.text) {
                    WalletGenerator().createWallet(userName.text!, password: createPassword.text!)
                    
                    State.fromVC = SegueToRegistrationVC
                    State.toVC = SegueToLoginVC
                    
                    if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                        (self.delegate as! MainVCDelegate).pageSelected(SegueToLoginVC)
                    }
                }
                else {
                    alert  = UIAlertView(title: "VALIDATION".localized(), message: "PASSOWORD_DIFERENCE_ERROR".localized(), delegate: self, cancelButtonTitle: "OK".localized())
                }
            }
            else {
                alert  = UIAlertView(title: "VALIDATION".localized(), message: "PASSOWORD_LENGTH_ERROR".localized(), delegate: self, cancelButtonTitle: "OK")
            }
        }
        else {
                        
            alert  = UIAlertView(title: "VALIDATION".localized(), message: "FIELDS_EMPTY_ERROR".localized(), delegate: self, cancelButtonTitle: "OK")
        }
        
        if(alert != nil) {
            alert.show()
        }
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight - 10, 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 15, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
