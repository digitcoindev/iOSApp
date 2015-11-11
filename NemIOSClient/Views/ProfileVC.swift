import UIKit

class ProfileVC: AbstractViewController, UITableViewDataSource, UITableViewDelegate, APIManagerDelegate, ChangeNamePopUptDelegate
{
    private enum ProfileTab :Int {
        case PrivateKey = 6
        case History = 7
        case Multisig = 8
        case PrimariAccount = 9
        case AccuntName = 10
        case exportAccount = 11
    }
    
    let dataManager :CoreDataManager = CoreDataManager()
    var walletData :AccountGetMetaData!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    
    private var _mainAccount :AccountGetMetaData? = nil
    private let _apiManager :APIManager =  APIManager()
    
    private var _titles :[String] = []
    private var _content :[String] = []
    
    private var _popUp :AbstractViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToProfile
        State.currentVC = SegueToProfile
        
        _apiManager.delegate = self
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        let address :String = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
                
        _apiManager.accountGet(State.currentServer!, account_address: address)
        
        _titles += [
            NSLocalizedString("ACCOUNT_NAME", comment: "Title") + ":",
            NSLocalizedString("ACCOUNT_ADDRESS", comment: "Title") + ":",
            NSLocalizedString("ACCOUNT_TYPE", comment: "Title") + ":",
            NSLocalizedString("IMPORTANCE_SCORE", comment: "Title") + ":",
            NSLocalizedString("PUBLIC_KEY", comment: "Title") + ":",
            NSLocalizedString("DELEGATED_PRIVATE_KEY", comment: "Title") + ":",
            NSLocalizedString("PRIVATE_KEY", comment: "Title") + ":",
            NSLocalizedString("ACCOUNT_HISTORY", comment: "Title") + ":",
            NSLocalizedString("MULTISIG", comment: "Title") + ":",
            NSLocalizedString("PRIMARY_ACCOUNT", comment: "Title") + ":",
            NSLocalizedString("ACCOUNT_NAME", comment: "Title") + ":",
            NSLocalizedString("EXPORT_ACCOUNT", comment: "Title") + ":"
        ]
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    @IBAction func changePassword(sender: AnyObject) {
        let alert1 :UIAlertController = UIAlertController(title: "Change password", message: "Input your data", preferredStyle: UIAlertControllerStyle.Alert)
        
        var oldPassword :UITextField!
        alert1.addTextFieldWithConfigurationHandler {
                textField -> Void in
                textField.placeholder = "old password"
                textField.keyboardType = UIKeyboardType.ASCIICapable
                textField.returnKeyType = UIReturnKeyType.Next
                textField.secureTextEntry = true
                
                oldPassword = textField
                
        }
        
        var newPassword :UITextField!
        alert1.addTextFieldWithConfigurationHandler {
                textField -> Void in
                textField.placeholder = "new password"
                textField.keyboardType = UIKeyboardType.ASCIICapable
                textField.returnKeyType = UIReturnKeyType.Next
                textField.secureTextEntry = true
                
                newPassword = textField
                
        }
        
        var repeatPassword :UITextField!
        alert1.addTextFieldWithConfigurationHandler {
                textField -> Void in
                textField.placeholder = "repeat password"
                textField.keyboardType = UIKeyboardType.ASCIICapable
                textField.returnKeyType = UIReturnKeyType.Done
                textField.secureTextEntry = true
                
                repeatPassword = textField
                
        }
        
        let change :UIAlertAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default) {
                alertAction -> Void in
                
                var isError :Bool = false
                
                let salt :NSData = NSData.fromHexString(State.currentWallet!.salt)
                
                let passwordHash :NSData? = try? HashManager.generateAesKeyForString(oldPassword.text!, salt:salt, roundCount:2000)!
                
                if passwordHash!.toHexString() != State.currentWallet!.password {
                    alert1.message = "Wrong old password"
                    oldPassword.text = ""
                    isError = true
                }
                
                if newPassword.text != repeatPassword.text {
                    alert1.message = "Passwords not equal"
                    repeatPassword.text = ""
                    newPassword.text = ""
                    isError = true
                }
                
                if !Validate.password(newPassword.text!) {
                    alert1.message = "PASSOWORD_LENGTH_ERROR"
                    repeatPassword.text = ""
                    newPassword.text = ""
                    isError = true
                }
                
                if !isError {
                    let passwordHash :NSData? = try? HashManager.generateAesKeyForString(newPassword.text!, salt:salt, roundCount:2000)!
                    
                    State.currentWallet!.password = passwordHash!.toHexString()
                    State.currentWallet!.salt = salt.toHexString()
                    
                    CoreDataManager().commit()
                }
                else {
                    self.presentViewController(alert1, animated: true, completion: nil)
                }
            }
        
        
        let cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) {
                alertAction -> Void in
            }
        
        alert1.addAction(cancel)
        alert1.addAction(change)
        
        self.presentViewController(alert1, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(_content.count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if _content.count == 0 {
            return self.tableView!.dequeueReusableCellWithIdentifier("Loading")!
        }
        
        var cell :ProfileTableViewCell!
        if indexPath.row < 6 {
            cell = self.tableView!.dequeueReusableCellWithIdentifier("type one") as! ProfileTableViewCell
        } else {
            cell = self.tableView!.dequeueReusableCellWithIdentifier("type two") as! ProfileTableViewCell
        }
        
        cell.title.text = _titles[indexPath.row]
        cell.contentLabel.text = _content[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case ProfileTab.History.rawValue:
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToHistoryVC)
            }
        case ProfileTab.Multisig.rawValue :
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueTomultisigAccountManager)
            }
        case ProfileTab.AccuntName.rawValue:
            _createPopUp("ChangeNamePopUpProfile")
            
        default:
            break
        }
    }
    
    //MARK: - Private Methods
    
    private final func _createPopUp(withId: String) {
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popUpController :AbstractViewController =  storyboard.instantiateViewControllerWithIdentifier(withId) as! AbstractViewController
        popUpController.view.frame = CGRect(x: 0, y: topView.frame.height, width: popUpController.view.frame.width, height: popUpController.view.frame.height - topView.frame.height)
        popUpController.view.layer.opacity = 0
        popUpController.delegate = self
        
        _popUp = popUpController
        self.view.addSubview(popUpController.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            popUpController.view.layer.opacity = 1
            }, completion: nil)

    }
    
    //MARK: - ChangeNamePopUpDelegate Methods

    func nameChanged(name :String) {
        _content[0] = name
        tableView.reloadData()
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        
        if account != nil {
            
            _mainAccount = account
            
            var type :String = ""
            if account!.cosignatories.count > 0 {
                type = NSLocalizedString("MULTISIG_ACCOUNT", comment: "Description")
            } else if account!.cosignatoryOf.count > 0 {
                type = NSLocalizedString("COSIGNER_ACCOUNT", comment: "Description")
            } else {
                type = NSLocalizedString("NORMAL_ACCOUNT", comment: "Description")
            }
            
            let importance = account!.importance.format(".2") + " ‱"
            
            _content = []
            _content += [
                State.currentWallet!.login,
                account!.address.nemAddressNormalised(),
                type,
                importance,
                KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey)),
                HashManager.SHA256Encrypt(HashManager.AES256Decrypt(State.currentWallet!.privateKey).asByteArray())
            ]
            _content += [
                NSLocalizedString("GET_PRIVATE_KEY", comment: "Description") + "(Disabled)",
                NSLocalizedString("VIEW_ACCOUNT_HISTORY", comment: "Description"),
                NSLocalizedString("ADD_OR_REMOVE_COSIGNERS", comment: "Description"),
                NSLocalizedString("SET_PRIMARY_ACCOUNT", comment: "Description") + "(Disabled)",
                NSLocalizedString("CHANGE_ACCOUNT_NAMET", comment: "Description"),
                NSLocalizedString("CREATE_QR", comment: "Description"  + "(Disabled)")
            ]
            
            tableView.reloadData()
        }
    }
}
