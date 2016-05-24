import UIKit
import LocalAuthentication

class PasswordValidationVC: AbstractViewController
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var topView: UIView!
    
    let dataMeneger: CoreDataManager  = CoreDataManager()
    
    private var _showTouchId = true
    
    // MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToPasswordValidation
        
        passwordTitle.text = "ENTET_PASSWORD".localized()
        password.placeholder = "   " + "PASSWORD_PLACEHOLDER".localized()
        password.text = "qwerty"

        confirm.setTitle("CONFIRM".localized(), forState: UIControlState.Normal)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        if self.delegate != nil && State.countVC > 0 {
            topView.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        super.viewDidAppear(animated)
        
        _showTouchId = true
        applicationDidBecomeActive(nil)
    }
    
    func applicationDidBecomeActive(notification: NSNotification?) {
        if State.importAccountData == nil && (State.loadData?.touchId ?? true) as Bool && _showTouchId{
            _showTouchId = false
            authenticateUser()
        }
    }
    
    override func  viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        State.importAccountData = nil

        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func passwordValidation(sender: AnyObject) {
        password.endEditing(true)

        if State.importAccountData != nil {
            _validateFromImport()
            return
        }
        
        _validateFromDatabase()
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject) {
        (sender as! UITextField).becomeFirstResponder()
    }
    // MARK: - Private Methods
    
    private func _validateFromImport() {
        
        let success = State.importAccountData?(password: password.text!) ?? false
        if success {
            State.importAccountData = nil
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
        
    private func _validateFromDatabase() {
        
        guard let salt = State.loadData?.salt else {return}
        guard let saltData :NSData = NSData.fromHexString(salt) else {return}
        guard let passwordValue = State.loadData?.password else {return}
        
        let passwordData :NSData? = try? HashManager.generateAesKeyForString(password.text!, salt:saltData, roundCount:2000)!
        
        if passwordData?.toHexString() == passwordValue {
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // MARK: - Touch Id
    
    func authenticateUser() {
        
        let context = LAContext()
        context.maxBiometryFailures = 10
        var error: NSError?
        let reasonString = "Authentication is needed to access messages."
        
        context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
        context.localizedFallbackTitle = ""
        
        [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
            self._showTouchId = false

            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
                        (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            } else {

                print(evalPolicyError!.localizedDescription)
                
                switch evalPolicyError!.code {
                    
                case LAError.SystemCancel.rawValue:
                    self._showTouchId = true
                    print("Authentication was cancelled by the system")
                    
                case LAError.UserCancel.rawValue:
                    print("Authentication was cancelled by the user")
                    
                case LAError.UserFallback.rawValue:
                    self._showTouchId = true
                    print("User selected to enter custom password")
                default:
                    print("Authentication failed")
                }
            }
            
        })]
        if error != nil
        {
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                print("A passcode has not been set")
                
            default:
                print("TouchID not available")
            }
            
            print(error!.localizedDescription)
        }
    }
}
