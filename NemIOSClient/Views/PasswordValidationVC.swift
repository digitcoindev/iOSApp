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

    override func viewDidLoad()
    {
        super.viewDidLoad()

        State.currentVC = SegueToPasswordValidation
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        currentField = password
        authenticateUser()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - IBAction
    
    @IBAction func passwordValidation(sender: AnyObject)
    {
        var salt :NSData = NSData.fromHexString(State.currentWallet!.salt)
        
        let passwordHash :NSData? = HashManager.generateAesKeyForString(password.text, salt:salt, roundCount:2000, error:nil)
        
        if( passwordHash!.toHexString() == State.currentWallet!.password)
        {
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(State.toVC)
            }
        }
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject)
    {
        (sender as! UITextField).becomeFirstResponder()
    }

    // MARK: - Touch Id

    func authenticateUser() {
        
        let context = LAContext()
        context.maxBiometryFailures = 10
        var error: NSError?
        var reasonString = "Authentication is needed to access messages."
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.localizedFallbackTitle = ""

            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                        (self.delegate as! MainVCDelegate).pageSelected(State.toVC)
                    }
                }
                else{
                    println(evalPolicyError!.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        println("Authentication was cancelled by the system")
                        
                    case LAError.UserCancel.rawValue:
                        println("Authentication was cancelled by the user")
                        
                    case LAError.UserFallback.rawValue:
                        println("User selected to enter custom password")
                        
                    default:
                        println("Authentication failed")
                    }
                }
                
            })]
        }
        else{
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                println("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                println("A passcode has not been set")
                
            default:
                println("TouchID not available")
            }
            
            println(error!.localizedDescription)
            
        }
    }
}
