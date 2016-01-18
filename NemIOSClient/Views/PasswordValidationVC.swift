import UIKit
import LocalAuthentication

class PasswordValidationVC: AbstractViewController
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var passwordTitle: UILabel!
    
    let dataMeneger: CoreDataManager  = CoreDataManager()
    
    // MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToPasswordValidation
        
        if State.nextVC == SegueToExportAccount {
            passwordTitle.text = "ENTET_PASSWORD_EXPORT".localized()
            password.placeholder = "PASSWORD_PLACEHOLDER_EXPORT".localized()
        } else {
            passwordTitle.text = "ENTET_PASSWORD".localized()
            password.placeholder = "PASSWORD_PLACEHOLDER".localized()
        }

        confirm.setTitle("CONFIRM".localized(), forState: UIControlState.Normal)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        if State.importAccountData == nil && (State.loadData?.touchId ?? true) as Bool &&  State.nextVC != SegueToExportAccount {
            authenticateUser()
        } 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    
    @IBAction func passwordValidation(sender: AnyObject) {
        password.endEditing(true)
        
        if State.nextVC == SegueToExportAccount {
            _prepareForExport()
            return
        }

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
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
            }
        }
    }
    
    private func _prepareForExport() {
        
        let login = State.currentWallet!.login
        
        let salt = State.loadData!.salt!
        var privateKey_AES = State.currentWallet!.privateKey
        
        if password.text != "" {
            let privateKey = HashManager.AES256Decrypt(privateKey_AES, key: State.loadData!.password!)
            let saltData = NSData(bytes: salt.asByteArray())
            let passwordHash :NSData? = try? HashManager.generateAesKeyForString(password.text!, salt:saltData, roundCount:2000)!
            privateKey_AES = HashManager.AES256Encrypt(privateKey!, key: passwordHash!.hexadecimalString())
        }
        
        let objects = [login, salt, privateKey_AES]
        let keys = [QRKeys.Name.rawValue, QRKeys.Salt.rawValue, QRKeys.PrivateKey.rawValue]
        
        let jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects, forKeys: keys)
        let jsonDictionary :NSDictionary = NSDictionary(objects: [QRType.AccountData.rawValue, jsonAccountDictionary, QR_VERSION], forKeys: [QRKeys.DataType.rawValue, QRKeys.Data.rawValue, QRKeys.Version.rawValue])
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        let jsonString :String = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
        State.exportAccount = jsonString
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
        }
    }
    
    private func _validateFromDatabase() {
        
        guard let salt = State.loadData?.salt else {return}
        guard let saltData :NSData = NSData.fromHexString(salt) else {return}
        guard let passwordValue = State.loadData?.password else {return}
        
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
