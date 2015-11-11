import UIKit

class ImportFromKey: AbstractViewController ,UIScrollViewDelegate
{
    //MARK: - IBOulets

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var key: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToImportFromKey
        State.currentVC = SegueToImportFromKey

        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        if State.countVC <= 1 {
            backButton.hidden = true
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        validateField(sender)
        
        scroll.scrollRectToVisible(sender.convertRect(sender.frame, toView: self.view), animated: true)
    }
    
    @IBAction func validateField(sender: UITextField){
        
        switch sender {
        case password , repeatPassword:
            
            if Validate.password(password.text!){
                sender.textColor = UIColor.greenColor()
            } else {
                sender.textColor = UIColor.redColor()
            }
            
            if sender.text != password.text{
                sender.textColor = UIColor.redColor()
            }
            
            if sender.text == "" {
                sender.textColor = UIColor.blackColor()
            }
            
        case key:
            
            if Validate.key(key.text) {
                sender.textColor = UIColor.greenColor()
            }
            else {
                sender.textColor = UIColor.redColor()
            }
            
        default:
            break
        }
    }
    
    @IBAction func confirm(sender: AnyObject) {
        var alert :UIAlertView!
        if name.text != ""  && key.text! != "" && repeatPassword.text != "" && password.text != "" {
            if password.text == repeatPassword.text && Validate.password(password.text!) {
                var keyValide :Bool = true
                switch (key.text!) {
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
                    
                case "10":
                    
                    key.text = "906ddbd7052149d7f45b73166f6b64c2d4f2fdfb886796371c0e32c03382bf33"
                    
                default:
                    
                    keyValide = Validate.key(key.text)
                }
                
                if let privateKey = key.text!.nemKeyNormalized() {
                    WalletGenerator().createWallet(name.text!, password: password.text!, privateKey: privateKey)
                    
                    State.fromVC = SegueToImportFromKey
                    State.toVC = SegueToLoginVC
                    
                    if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                        (self.delegate as! MainVCDelegate).pageSelected(SegueToLoginVC)
                    }
                }
                else {
                    alert  = UIAlertView(title: NSLocalizedString("VALIDATION", comment: "Title"), message: NSLocalizedString("PRIVATE_KEY_ERROR_1", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
                }
            }
            else if !Validate.password(password.text!) {
                alert  = UIAlertView(title: NSLocalizedString("VALIDATION", comment: "Title"), message: NSLocalizedString("PASSOWORD_LENGTH_ERROR", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
                
                repeatPassword.text = ""
            }
            else {
                alert  = UIAlertView(title: NSLocalizedString("VALIDATION", comment: "Title"), message: NSLocalizedString("PASSOWORD_DIFERENCE_ERROR", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
                
                repeatPassword.text = ""
            }
        }
        else {
            alert  = UIAlertView(title: NSLocalizedString("VALIDATION", comment: "Title"), message: NSLocalizedString("FIELDS_EMPTY_ERROR", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
            
        }
        
        if(alert != nil) {
            alert.show()
        }
    }
    
    @IBAction func changeField(sender: UITextField) {
        switch sender {
        case key:
            
            name.becomeFirstResponder()
            chouseTextField(name)
            
        case name:
            
            password.becomeFirstResponder()
            chouseTextField(password)
            
        case password:
            
            repeatPassword.becomeFirstResponder()
            chouseTextField(repeatPassword)
            
        default :
            break
        }
    }
    
    //MARK: - Keyboard Delegate
    
    final func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight - 15, 0)
        scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight + 15, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
