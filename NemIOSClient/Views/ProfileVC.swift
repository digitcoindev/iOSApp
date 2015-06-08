import UIKit

class ProfileVC: UIViewController , UITableViewDataSource , UITableViewDelegate ,UIScrollViewDelegate
{
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
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

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if keyValidator != nil
        {
            keyValidator.hidden = true
            addCosignatori.autocorrectionType = UITextAutocorrectionType.No
        }
        
        State.currentVC = SegueToProfile
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Profile")

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.layer.cornerRadius = 5

        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "prepareAnnounceSuccessed:", name: "prepareAnnounceSuccessed", object: nil)
        observer.addObserver(self, selector: "prepareAnnounceDenied:", name: "prepareAnnounceDenied", object: nil)

        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        
        observer.addObserver(self, selector: "deleteCellAtIndex:", name: "deleteCellAtIndex", object: nil)
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
        if State.currentServer != nil
        {
            var address :String = AddressGenerator().generateAddressFromPrivateKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
                
            apiManager.accountGet(State.currentServer!, account_address: address)
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }
                
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    final func manageState()
    {
        switch (state.last!)
        {
        case "accountGetSuccessed" :
            var stateWallet = State.currentWallet!
            
            userLogin.text = stateWallet.login
            userAddress.text =  AddressGenerator().generateAddressFromPrivateKey(HashManager.AES256Decrypt(stateWallet.privateKey))
            
            if walletData.cosignatories.count > 0
            {
                accountType.text = "multisign account"
                
                if State.fromVC != SegueToProfileMultisig
                {
                    State.fromVC = SegueToProfileMultisig
                }
                
                State.currentVC = SegueToProfileMultisig
                
                for account in walletData.cosignatories
                {
                    currentCosignatories.append(account.publicKey as String)
                }
            }
            else if walletData.cosignatoryOf.count > 0
            {
                accountType.text = "is cosignatory"
                
                if State.fromVC != SegueToProfileCosignatoryOf
                {
                    State.fromVC = SegueToProfileCosignatoryOf
                }
                
                State.currentVC = SegueToProfileCosignatoryOf
                
                for account in walletData.cosignatoryOf
                {
                    currentCosignatories.append(account.publicKey as String)
                }
            }
            else
            {
                if State.fromVC != SegueToProfile
                {
                    State.fromVC = SegueToProfile
                }
                
                State.currentVC = SegueToProfile
                
                accountType.text = "simple account"
            }
            
            state.removeLast()
            
//            if self.currentCosignatories.count == 0
//            {
//                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.width, 0)
//                self.tableView.becomeFirstResponder()
//            }
            
            self.tableView.reloadData()
            
        case "prepareAnnounceSuccessed" :
            state.removeLast()
            var alert1 :UIAlertController = UIAlertController(title: "Info", message: "Changes are confirmed and\nwill be confirmed in a few hours", preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive)
                {
                    alertAction -> Void in
            }
            
            alert1.addAction(ok)
            self.presentViewController(alert1, animated: true, completion: nil)
            
        case "prepareAnnounceDenied" :
            state.removeLast()
            var alert1 :UIAlertController = UIAlertController(title: "Info", message: "Changes waere not confirmed,\nplease try again later.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive)
                {
                    alertAction -> Void in
            }
            
            alert1.addAction(ok)
            self.presentViewController(alert1, animated: true, completion: nil)
            
        default :
            break
        }
    }
    
    final func prepareAnnounceSuccessed(notification: NSNotification)
    {
        state.append("prepareAnnounceSuccessed")
        
    }
    
    final func prepareAnnounceDenied(notification: NSNotification)
    {
        state.append("prepareAnnounceDenied")
    }
    
    final func accountGetSuccessed(notification: NSNotification)
    {
        state.append("accountGetSuccessed")
        
        walletData = (notification.object as! AccountGetMetaData)
    }
    
    final func accountGetDenied(notification: NSNotification)
    {
        state.append("accountGetDenied")
    }
    
    final func deleteCellAtIndex(notification: NSNotification)
    {
        var index = notification.object as! Int
        var indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        currentCosignatories.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([indexPath] , withRowAnimation: .Fade)
    }
    
    @IBAction func changePassword(sender: AnyObject)
    {
        var alert1 :UIAlertController = UIAlertController(title: "Change password", message: "Input your data", preferredStyle: UIAlertControllerStyle.Alert)
        
        var oldPassword :UITextField!
        alert1.addTextFieldWithConfigurationHandler
            {
                textField -> Void in
                textField.placeholder = "old password"
                textField.keyboardType = UIKeyboardType.ASCIICapable
                textField.returnKeyType = UIReturnKeyType.Next
                textField.secureTextEntry = true
                
                oldPassword = textField
                
        }
        
        var newPassword :UITextField!
        alert1.addTextFieldWithConfigurationHandler
            {
                textField -> Void in
                textField.placeholder = "new password"
                textField.keyboardType = UIKeyboardType.ASCIICapable
                textField.returnKeyType = UIReturnKeyType.Next
                textField.secureTextEntry = true
                
                newPassword = textField
                
        }
        
        var repeatPassword :UITextField!
        alert1.addTextFieldWithConfigurationHandler
            {
                textField -> Void in
                textField.placeholder = "repeat password"
                textField.keyboardType = UIKeyboardType.ASCIICapable
                textField.returnKeyType = UIReturnKeyType.Done
                textField.secureTextEntry = true
                
                repeatPassword = textField
                
        }
        
        var change :UIAlertAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default)
            {
                alertAction -> Void in
                
                var isError :Bool = false
                
                var salt :NSData = HashManager.salt(length: 128)
                
                let passwordHash :NSData? = HashManager.generateAesKeyForString(oldPassword.text, salt:salt, roundCount:2000, error:nil)
                
                if passwordHash != HashManager.AES256Decrypt(State.currentWallet!.password)
                {
                    alert1.message = "Wrong old password"
                    oldPassword.text = ""
                    isError = true
                }
                
                if newPassword.text != repeatPassword.text
                {
                    alert1.message = "Passwords not equal"
                    repeatPassword.text = ""
                    newPassword.text = ""
                    isError = true
                }
                
                if !isError
                {
                    var salt :NSData = HashManager.salt(length: 128)
                    
                    let passwordHash :NSData? = HashManager.generateAesKeyForString(newPassword.text, salt:salt, roundCount:2000, error:nil)
                    
                    State.currentWallet!.password = passwordHash!.toHexString()
                    State.currentWallet!.salt = salt.toHexString()
                    
                    CoreDataManager().commit()
                }
                else
                {
                    self.presentViewController(alert1, animated: true, completion: nil)
                }
            }
        
        
        var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive)
            {
                alertAction -> Void in
            }
        
        alert1.addAction(cancel)
        alert1.addAction(change)
        
        self.presentViewController(alert1, animated: true, completion: nil)
    }
    
    @IBAction func getRect(sender: NEMTextField)
    {
        showRect = sender.frame
    }
    
    @IBAction func typing(sender: NEMTextField)
    {
        if Swift.count(sender.text.utf16) == 64
        {
            keyValidator.hidden = false
        }
        else
        {
            keyValidator.hidden = true
        }
    }
    
    @IBAction func addChanges(sender: AnyObject)
    {
        var newPublicKey :String = (sender as! UITextField).text
        if Swift.count(newPublicKey.utf16) == 64
        {
            var find : Bool = false
            for publicKey in currentCosignatories
            {
                if publicKey == newPublicKey
                {
                    find = true
                    break
                }
            }
            
            if !find
            {
                currentCosignatories.append(newPublicKey)
                tableView.reloadData()
            }
            
            (sender as! UITextField).text = ""
        }
    }
    
    @IBAction func history(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToHistoryVC )
    }
    
    @IBAction func manageAccount(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueTomultisigAccountManager )
    }
    
    @IBAction func saveChanges(sender: AnyObject)
    {
        removeArray = walletData.cosignatories
        
        for publicKey in currentCosignatories
        {
            var find = false
            for var index = 0 ; index < removeArray.count ;index++
            {
                if publicKey == removeArray[index].publicKey as String
                {
                    find = true
                    removeArray.removeAtIndex(index)
                }
            }
            
            if !find
            {
                addArray.append(publicKey)
            }
        }
        
        if removeArray.count > 1
        {
            var alert :UIAlertController = UIAlertController(title: "Info", message: "Yikes. You can remove only one cosignatori per transaction.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive)
                {
                    alertAction -> Void in
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.tableView.reloadData()
            }
            
            alert.addAction(ok)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if (addArray.count - removeArray.count + walletData.cosignatories.count) > 16
        {
            var alert :UIAlertController = UIAlertController(title: "Info", message: "Yikes. Too many cosignatories.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive)
                {
                    alertAction -> Void in
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.tableView.reloadData()
            }
            
            alert.addAction(ok)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            var fee = 10 + 6 * Int64(addArray.count + removeArray.count)
            
            var alert1 :UIAlertController = UIAlertController(title: "Confirmation", message: "Are you agree with changes? It will cost \(fee) XEM", preferredStyle: UIAlertControllerStyle.Alert)
            
            var confirm :UIAlertAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default)
                {
                    alertAction -> Void in
                    
                    var transaction :AggregateModificationTransaction = AggregateModificationTransaction()
                    var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
                    var publickey = KeyGenerator().generatePublicKey(privateKey)
                    
                    transaction.timeStamp = TimeSynchronizator.nemTime
                    transaction.deadline = TimeSynchronizator.nemTime + waitTime
                    transaction.version = 1
                    transaction.signer = publickey
                    transaction.privateKey = privateKey
                    
                    for cosignatori in self.removeArray
                    {
                        transaction.addModification(2, publicKey: cosignatori.publicKey as String)
                    }
                    
                    for publickey in self.addArray
                    {
                        transaction.addModification(1, publicKey: publickey)
                    }
                    
                    transaction.fee = 10 + 6 * Double(self.addArray.count + self.removeArray.count)
                    
                    APIManager().prepareAnnounce(State.currentServer!, transaction: transaction)

                }
            
            
            var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive)
                {
                    alertAction -> Void in
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.tableView.reloadData()
                }
            
            alert1.addAction(cancel)
            alert1.addAction(confirm)
            
            self.presentViewController(alert1, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentCosignatories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell :KeyCell = self.tableView.dequeueReusableCellWithIdentifier("KeyCell") as! KeyCell
        
        cell.key.text = ""
        cell.cellIndex = indexPath.row
        
        cell.key.text = cell.key.text! + currentCosignatories[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration = 0.1
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.scroll.scrollRectToVisible(showRect, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
