import UIKit

class MultisigAccountManager: AbstractViewController  , UITableViewDelegate
{

    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var chooseAccount: ButtonDropDown!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyValidator: UIImageView!

    @IBOutlet weak var lableTableOf: UILabel!
    @IBOutlet weak var inputField: NEMTextField!
    @IBOutlet weak var background: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var walletData :AccountGetMetaData!
    var timer :NSTimer!
    var state :[String] = ["none"]
    var showRect :CGRect = CGRectZero

    var currentCosignatories :[String] = [String]()
    var removeArray :[AccountGetMetaData]!
    var addArray = [String]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if State.fromVC != SegueTomultisigAccountManager
        {
            State.fromVC = SegueTomultisigAccountManager
        }
        
        State.currentVC = SegueTomultisigAccountManager
        
        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        
        observer.addObserver(self, selector: "prepareAnnounceSuccessed:", name: "prepareAnnounceSuccessed", object: nil)
        observer.addObserver(self, selector: "prepareAnnounceDenied:", name: "prepareAnnounceDenied", object: nil)
        
        observer.addObserver(self, selector: "deleteCellAtIndex:", name: "deleteCellAtIndex", object: nil)
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        observer.postNotificationName("Title", object:"Manage Account" )
        
        lableTableOf.hidden = true
        background.hidden = true
        inputField.hidden = true
        saveButton.hidden = true
        keyValidator.hidden = true
        scroll.scrollEnabled = false
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var account_address = AddressGenerator().generateAddressFromPrivateKey(privateKey)
        
        if State.currentServer != nil
        {
            APIManager().accountGet(State.currentServer!, account_address: account_address)
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
    }
    
    final func manageState()
    {
        switch (state.last!)
        {
        case "accountGetSuccessed" :
            var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
            var publicKey = KeyGenerator().generatePublicKey(privateKey)
            
            if publicKey == walletData.publicKey
            {
                var content :[String] = [String]()
                var contentActions :[funcBlock] = [funcBlock]()
                
                if  walletData.cosignatoryOf.count == 0
                {
                    content.append("This account")
                    contentActions.append(
                        {
                            () -> () in
                            
                            if State.currentServer != nil
                            {
                                APIManager().accountGet(State.currentServer!, account_address: self.walletData.address)
                            }
                    })
                }
                else
                {
                    for account in walletData.cosignatoryOf
                    {
                        content.append(account.address)
                        contentActions.append(
                            {
                                () -> () in
                                
                                if State.currentServer != nil
                                {
                                    APIManager().accountGet(State.currentServer!, account_address: account.address)
                                }
                        })
                    }
                }
                chooseAccount.setContent(content, contentActions: contentActions)
            }
            else
            {
                lableTableOf.hidden = false
                background.hidden = false
                inputField.hidden = false
                saveButton.hidden = false
                keyValidator.hidden = false
                scroll.scrollEnabled = true

                for account in walletData.cosignatories
                {
                    currentCosignatories.append(account.publicKey as String)
                }
                self.tableView.reloadData()
            }
            
            state.removeLast()
            
        case "prepareAnnounceSuccessed" :
            state.removeLast()
            var alert1 :UIAlertController = UIAlertController(title: "Info", message: "Changes are confirmed and await \nfor server validation", preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive)
                {
                    alertAction -> Void in
            }
            
            alert1.addAction(ok)
            self.presentViewController(alert1, animated: true, completion: nil)
            
        case "prepareAnnounceDenied" :
            state.removeLast()
            var alert1 :UIAlertController = UIAlertController(title: "Info", message: "Changes are not confirmed,\nplease try again later.", preferredStyle: UIAlertControllerStyle.Alert)
            
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

    final func accountGetSuccessed(notification: NSNotification)
    {
        state.append("accountGetSuccessed")
        
        walletData = (notification.object as! AccountGetMetaData)
    }
    
    final func accountGetDenied(notification: NSNotification)
    {
        state.append("accountGetDenied")
    }
    
    final func prepareAnnounceSuccessed(notification: NSNotification)
    {
        state.append("prepareAnnounceSuccessed")
        
    }
    
    final func prepareAnnounceDenied(notification: NSNotification)
    {
        state.append("prepareAnnounceDenied")
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
    
    final func deleteCellAtIndex(notification: NSNotification)
    {
        var index = notification.object as! Int
        var indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        currentCosignatories.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([indexPath] , withRowAnimation: .Fade)
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
            keyValidator.hidden = true

        }
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
    
    @IBAction func getRect(sender: NEMTextField)
    {
        showRect = sender.frame
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
                    var publickey = self.walletData.publicKey
                    
                    transaction.timeStamp = TimeSynchronizator.nemTime
                    transaction.deadline = TimeSynchronizator.nemTime + waitTime
                    transaction.version = 1
                    transaction.signer = publickey
                    transaction.privateKey = privateKey
                    transaction.minCosignatory = self.walletData.cosignatories.count - self.removeArray.count + self.addArray.count
                    
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
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.addArray.removeAll(keepCapacity: false)
                    self.removeArray.removeAll(keepCapacity: false)
                    
                    self.tableView.reloadData()
                    
            }
            
            
            var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive)
                {
                    alertAction -> Void in
                    
                    self.currentCosignatories.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatories
                    {
                        self.currentCosignatories.append(cosignatory.publicKey as String)
                    }
                    
                    self.addArray.removeAll(keepCapacity: false)
                    self.removeArray.removeAll(keepCapacity: false)
                    
                    self.tableView.reloadData()
            }
            
            alert1.addAction(cancel)
            alert1.addAction(confirm)
            
            self.presentViewController(alert1, animated: true, completion: nil)
        }
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

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
}
