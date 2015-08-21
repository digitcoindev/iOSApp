import UIKit

class ProfileVC: AbstractViewController , UITableViewDataSource , UITableViewDelegate ,UIScrollViewDelegate
{
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var userLogin: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var keyValidator: UIImageView!
    @IBOutlet weak var addCosignatori: NEMTextField!
    @IBOutlet weak var accountType: UILabel!
    
    let dataManager :CoreDataManager = CoreDataManager()
    var walletData :AccountGetMetaData!
    
    var removeArray :[AccountGetMetaData]!
    var addArray = [String]()

    var apiManager :APIManager = APIManager()
    var count = 4
    var showRect :CGRect = CGRectZero
    var state :[String] = ["none"]
    var timer :NSTimer!
    
    var currentCosignatories :[String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if keyValidator != nil {
            keyValidator.hidden = true
            addCosignatori.autocorrectionType = UITextAutocorrectionType.No
        }
        
        State.currentVC = SegueToProfile
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Profile")
        if self.tableView != nil {
            self.tableView!.tableFooterView = UIView(frame: CGRectZero)
            self.tableView!.layer.cornerRadius = 5
        }

        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        
        if State.currentServer != nil {
            var address :String = AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
                
            apiManager.accountGet(State.currentServer!, account_address: address)
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }
                
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    final func manageState() {
        switch (state.last!) {
        case "accountGetSuccessed" :
            var stateWallet = State.currentWallet!
            
            userLogin.text = stateWallet.login
            userAddress.text =  AddressGenerator.generateAddressFromPrivateKey(HashManager.AES256Decrypt(stateWallet.privateKey))
            
            if walletData.cosignatories.count > 0 {
                accountType.text = "multisign account"
                
                if State.fromVC != SegueToProfileMultisig {
                    State.fromVC = SegueToProfileMultisig
                }
                if State.currentVC == SegueToProfile {
                    State.currentVC = SegueToProfileMultisig
                }
                
                for account in walletData.cosignatories {
                    currentCosignatories.append(account.publicKey as String)
                }
            }
            else if walletData.cosignatoryOf.count > 0 {
                accountType.text = "is cosignatory"
                
                if State.fromVC != SegueToProfileCosignatoryOf {
                    State.fromVC = SegueToProfileCosignatoryOf
                }
                
                if State.currentVC == SegueToProfile {
                    State.currentVC = SegueToProfileCosignatoryOf
                }
                
                for account in walletData.cosignatoryOf {
                    currentCosignatories.append(account.publicKey as String)
                }
            }
            else {
                if State.fromVC != SegueToProfile {
                    State.fromVC = SegueToProfile
                }
                
                State.currentVC = SegueToProfile
                
                accountType.text = "simple account"
            }
            
            state.removeLast()
            
            
            if self.tableView != nil {
                self.tableView!.reloadData()
            }
            
        case "accountGetDenied":
            
            state.removeLast()

        default :
            break
        }
    }
    
    final func accountGetSuccessed(notification: NSNotification) {
        state.append("accountGetSuccessed")
        
        walletData = (notification.object as! AccountGetMetaData)
    }
    
    final func accountGetDenied(notification: NSNotification) {
        state.append("accountGetDenied")
    }
    
    final func deleteCellAtIndex(notification: NSNotification) {
        var index = notification.object as! Int
        var indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        currentCosignatories.removeAtIndex(index)
        self.tableView!.deleteRowsAtIndexPaths([indexPath] , withRowAnimation: .Fade)
    }
    
    @IBAction func changePassword(sender: AnyObject) {
        var alert1 :UIAlertController = UIAlertController(title: "Change password", message: "Input your data", preferredStyle: UIAlertControllerStyle.Alert)
        
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
        
        var change :UIAlertAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default) {
                alertAction -> Void in
                
                var isError :Bool = false
                
                var salt :NSData = NSData.fromHexString(State.currentWallet!.salt)
                
                let passwordHash :NSData? = HashManager.generateAesKeyForString(oldPassword.text, salt:salt, roundCount:2000, error:nil)
                
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
                
                if !Validate.password(newPassword.text) {
                    alert1.message = "PASSOWORD_LENGTH_ERROR"
                    repeatPassword.text = ""
                    newPassword.text = ""
                    isError = true
                }
                
                if !isError {
                    let passwordHash :NSData? = HashManager.generateAesKeyForString(newPassword.text, salt:salt, roundCount:2000, error:nil)
                    
                    State.currentWallet!.password = passwordHash!.toHexString()
                    State.currentWallet!.salt = salt.toHexString()
                    
                    CoreDataManager().commit()
                }
                else {
                    self.presentViewController(alert1, animated: true, completion: nil)
                }
            }
        
        
        var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive) {
                alertAction -> Void in
            }
        
        alert1.addAction(cancel)
        alert1.addAction(change)
        
        self.presentViewController(alert1, animated: true, completion: nil)
    }
    
    @IBAction func history(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToHistoryVC )
    }
    
    @IBAction func manageAccount(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueTomultisigAccountManager )
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCosignatories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell :KeyCell = self.tableView!.dequeueReusableCellWithIdentifier("KeyCell") as! KeyCell
        
        cell.key.text = ""
        cell.cellIndex = indexPath.row
        
        cell.key.text = cell.key.text! + currentCosignatories[indexPath.row]
        
        return cell
    }
}
