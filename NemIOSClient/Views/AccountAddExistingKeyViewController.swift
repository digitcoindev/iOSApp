import UIKit

class AccountAddExistingKeyViewController: AbstractViewController ,UIScrollViewDelegate
{
    //MARK: - IBOulets

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var key: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: #selector(AccountAddExistingKeyViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(AccountAddExistingKeyViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        title = "IMPORT_FROM_KEY".localized()
        
        key.placeholder = "PRIVATE_KEY".localized()
        name.placeholder = "NAME".localized()
        add.setTitle("ADD_ACCOUNT".localized(), forState: UIControlState.Normal)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        State.currentVC = SegueToImportFromKey
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction
    
    @IBAction func chouseTextField(sender: UITextField) {
        validateField(sender)
        
        scroll.scrollRectToVisible(sender.convertRect(sender.frame, toView: self.view), animated: true)
    }
    
    @IBAction func validateField(sender: UITextField){
        
        switch sender {
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
        
        if key.text! == "test" {
            let generator = WalletGenerator()
            
            for i in 1..<10 {
                let private_key = "000000000000000000000000000000000000000000000000000000000000000\(i)"
                
                if Validate.account(privateKey: private_key) == nil {
                    generator.createWallet("account \(i)", privateKey: private_key)
                }
            }
            
//            key.text = "906ddbd7052149d7f45b73166f6b64c2d4f2fdfb886796371c0e32c03382bf33"
//            name.text = "harvest"
            
            State.toVC = SegueToLoginVC
            
            performSegueWithIdentifier("unwindToAccountMainViewController", sender: nil)
            
            return
        }
        
        if name.text != ""  && key.text! != ""  {
            if let privateKey = key.text!.nemKeyNormalized() {
                if let name = Validate.account(privateKey: privateKey) {
                    alert  = UIAlertView(title: "VALIDATION".localized(), message: String(format: "VIDATION_ACCOUNT_EXIST".localized(), arguments:[name]), delegate: self, cancelButtonTitle: "OK".localized())
                } else {

                    WalletGenerator().createWallet(name.text!, privateKey: privateKey)
                    
                    
                    performSegueWithIdentifier("unwindToAccountMainViewController", sender: nil)
                }
            }
            else {
                alert  = UIAlertView(title: "VALIDATION".localized(), message: "PRIVATE_KEY_ERROR_1".localized(), delegate: self, cancelButtonTitle: "OK".localized())
            }
        }
        else {
            alert  = UIAlertView(title: "VALIDATION".localized(), message: "FIELDS_EMPTY_ERROR".localized(), delegate: self, cancelButtonTitle: "OK".localized())
            
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
            
            if key.text == "" {
                key.becomeFirstResponder()
                chouseTextField(key)
            }
            
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
