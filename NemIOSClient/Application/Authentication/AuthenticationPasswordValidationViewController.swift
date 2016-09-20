//
//  AuthenticationPasswordValidationViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import LocalAuthentication

class AuthenticationPasswordValidationViewController: UIViewController
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var passwordTitle: UILabel!
    
//    let dataMeneger: CoreDataManager  = CoreDataManager()
    
    fileprivate var _showTouchId = true
    
    // MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        State.currentVC = SegueToPasswordValidation
        
        passwordTitle.text = "ENTET_PASSWORD".localized()
        password.placeholder = "   " + "PASSWORD_PLACEHOLDER".localized()

        confirm.setTitle("CONFIRM".localized(), for: UIControlState())
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        super.viewDidAppear(animated)
        
        _showTouchId = true
        applicationDidBecomeActive(nil)
    }
    
    func applicationDidBecomeActive(_ notification: Notification?) {
        if State.importAccountData == nil && (State.loadData?.touchId ?? true) as Bool && _showTouchId{
            _showTouchId = false
            authenticateUser()
        }
    }
    
    override func  viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction

    @IBAction func editingDidBegin(_ sender: AnyObject) {
        password.textColor = UIColor.black
    }
    
    @IBAction func passwordValidation(_ sender: AnyObject) {
        password.endEditing(true)

        if State.importAccountData != nil {
            _validateFromImport()
            return
        }
        
        _validateFromDatabase()
    }
    
    @IBAction func hideKeyBoard(_ sender: AnyObject) {
        (sender as! UITextField).becomeFirstResponder()
    }
    // MARK: - Private Methods
    
    fileprivate func _validateFromImport() {
        
        let success = State.importAccountData?(password.text!) ?? false
        if success {
            State.importAccountData = nil
            
                performSegue(withIdentifier: "unwindToAccountMainViewController", sender: nil)

        }  else {
            password.textColor = UIColor.red
        }
    }
        
    fileprivate func _validateFromDatabase() {
        
        guard let salt = State.loadData?.salt else {return}
        guard let saltData :Data = Data.fromHexString(salt) else {return}
        guard let passwordValue = State.loadData?.password else {return}
        
        let passwordData :Data? = try! HashManager.generateAesKeyForString(password.text!, salt:saltData as NSData, roundCount:2000)! as Data?
        
        if passwordData?.toHexString() == passwordValue {
//            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
//            } else {
//                self.dismissViewControllerAnimated(true, completion: nil)
//            }
            self.dismiss(animated: true, completion: nil)
        } else {
            password.textColor = UIColor.red
        }
    }
    
    // MARK: - Touch Id
    
    func authenticateUser() {
        
        let context = LAContext()
        context.maxBiometryFailures = 10
        var error: NSError?
        let reasonString = "Authentication is needed to access messages."
        
        context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        context.localizedFallbackTitle = ""
        
        [context .evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
            self._showTouchId = false

            if success {
                DispatchQueue.main.async(execute: { () -> Void in
//                    if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//                        (self.delegate as! MainVCDelegate).pageSelected(State.nextVC)
//                    } else {
//                        self.dismissViewControllerAnimated(true, completion: nil)
//                    }
                    self.dismiss(animated: true, completion: nil)
                })
            } else {

                print(evalPolicyError!.localizedDescription)
                
                switch evalPolicyError!.code {
                    
                case LAError.Code.systemCancel.rawValue:
                    self._showTouchId = true
                    print("Authentication was cancelled by the system")
                    
                case LAError.Code.userCancel.rawValue:
                    print("Authentication was cancelled by the user")
                    
                case LAError.Code.userFallback.rawValue:
                    self._showTouchId = true
                    print("User selected to enter custom password")
                default:
                    print("Authentication failed")
                }
            }
            
        } as! (Bool, Error?) -> Void)]
        if error != nil
        {
            switch error!.code{
                
            case LAError.Code.touchIDNotEnrolled.rawValue:
                print("TouchID is not enrolled")
                
            case LAError.Code.passcodeNotSet.rawValue:
                print("A passcode has not been set")
                
            default:
                print("TouchID not available")
            }
            
            print(error!.localizedDescription)
        }
    }
}
