import UIKit
import LocalAuthentication

class PasswordValidationVC: AbstractViewController
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var showKeyboard :Bool = true
    var currentField :UITextField!
    let dataMeneger: CoreDataManager  = CoreDataManager()
    
    // MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToPasswordValidation
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        currentField = password
        
        if State.importAccountData == nil {
            authenticateUser()
        } 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    
    @IBAction func passwordValidation(sender: AnyObject) {
        password.becomeFirstResponder()

        if State.importAccountData != nil {
            _validateFromImport()
        } else {
            _validateFromDatabase()
        }
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject) {
        (sender as! UITextField).becomeFirstResponder()
    }
    // MARK: - Private Methods
    
    private func _validateFromImport() {
        
        let success = State.importAccountData?(password: password.text!) ?? false
        if success {
            State.importAccountData = nil
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
            }
        }
    }
    
    private func _validateFromDatabase() {
        
        guard let salt = State.currentWallet?.salt else {return}
        guard let saltData :NSData = NSData.fromHexString(salt) else {return}
        guard let passwordValue = State.currentWallet?.password else {return}
        
        let passwordData :NSData? = try? HashManager.generateAesKeyForString(password.text!, salt:saltData, roundCount:2000)!
        
        if passwordData?.toHexString() == passwordValue {
            
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
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
            
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                        (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
                    }
                })
            } else {
                print(evalPolicyError!.localizedDescription)
                
                switch evalPolicyError!.code {
                    
                case LAError.SystemCancel.rawValue:
                    print("Authentication was cancelled by the system")
                    
                case LAError.UserCancel.rawValue:
                    print("Authentication was cancelled by the user")
                    
                case LAError.UserFallback.rawValue:
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
