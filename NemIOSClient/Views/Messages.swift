import UIKit
import AddressBook

class Messages: UIViewController , UITableViewDelegate ,UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var key: UILabel!
    @IBOutlet weak var balance: UILabel!

    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    let dataManager : CoreDataManager = CoreDataManager()
    
    var state :[String] = ["none"]
    var timer :NSTimer!
    var walletData :AccountGetMetaData!
    
    var unconfirmedTransactions  :[TransactionPostMetaData] = [TransactionPostMetaData]()
    var findUnconfirmed = false
    var apiManager :APIManager = APIManager()
    var correspondents :[Correspondent]!
    var displayList :NSArray = NSArray()
    var searchBar : UISearchBar!
    var searchText :String = ""
    var showKeyboard :Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToMessages
        {
            State.fromVC = SegueToMessages
        }

        State.currentVC = SegueToMessages
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:"Dashboard")

        address.layer.cornerRadius = 2
        tableView.layer.cornerRadius = 2
        searchBar = UISearchBar(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 44)))
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        searchBar.showsCancelButton = false
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: false)

        correspondents = sortCorrespondents(State.currentWallet!.correspondents.allObjects as! [Correspondent])
        displayList = correspondents

        if AddressBookManager.isAllowed
        {
            findCorrespondentName()
        }
        
        refreshTransactionList()
        
        if (State.currentContact != nil && State.toVC == SegueToPasswordValidation )
        {
            State.toVC = SegueToMessageVC
            
            observer.postNotificationName("DashboardPage", object:SegueToPasswordValidation )
        }
        
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        observer.addObserver(self, selector: "unconfirmedTransactionsDenied:", name: "unconfirmedTransactionsDenied", object: nil)
        observer.addObserver(self, selector: "unconfirmedTransactionsSuccessed:", name: "unconfirmedTransactionsSuccessed", object: nil)
        observer.addObserver(self, selector: "accountTransfersAllDenied:", name: "accountTransfersAllDenied", object: nil)
        observer.addObserver(self, selector: "accountTransfersAllSuccessed:", name: "accountTransfersAllSuccessed", object: nil)
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    final func manageState()
    {
        switch (state.last!)
        {
        case "accountTransfersAllSuccessed" :
            
            correspondents = sortCorrespondents(State.currentWallet!.correspondents.allObjects as! [Correspondent])
            displayList = correspondents
            
            tableView.reloadData()
            state.removeLast()
            
        case "accountGetSuccessed" :
            var format = ".0"
            self.balance.text = "\((walletData.balance / 1000000).format(format))"
            if walletData.cosignatoryOf.count > 0
            {
                unconfirmedTransactions.removeAll(keepCapacity: false)
                findUnconfirmed = false
                
                for cosignatory in walletData.cosignatoryOf
                {
                    APIManager().unconfirmedTransactions(State.currentServer!, account_address: cosignatory.address)
                }
            }
            
            state.removeLast()
            
        case "accountGetDenied" :
            self.balance.text = "Lost connection"
            state.removeLast()
            
        case "unconfirmedTransactionsSuccessed" :
            
            for inTransaction in unconfirmedTransactions
            {
                switch(inTransaction.type)
                {
                case multisigTransaction:
                    var transaction :MultisigTransaction = inTransaction as! MultisigTransaction
                    var find = false
                    
                    for sign in transaction.signatures
                    {
                        if walletData.publicKey == sign.signer
                        {
                            find = true
                            break
                        }
                    }
                    
                    if inTransaction.signer != walletData.publicKey && !find
                    {
                        var alert :UIAlertController = UIAlertController(title: "Info", message: "You have unconfirmed transactions that need to be signed up!", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        var ok :UIAlertAction = UIAlertAction(title: "Show transactions", style: UIAlertActionStyle.Default)
                            {
                                alertAction -> Void in
                                
                                NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToUnconfirmedTransactionVC )

                            }
                        
                        var cancel :UIAlertAction = UIAlertAction(title: "Remind later", style: UIAlertActionStyle.Default)
                            {
                                alertAction -> Void in
                            }
                        
                        alert.addAction(cancel)
                        alert.addAction(ok)
                        
                        if !findUnconfirmed
                        {
                            findUnconfirmed = true
                            NSNotificationCenter.defaultCenter().removeObserver(self)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                    
                default:
                    break
                }
                
                if findUnconfirmed
                {
                    break
                }
            }
            state.removeLast()
            
        default :
            break
        }
    }
    
    final func findCorrespondentName()
    {
        var contacts :NSArray = AddressBookManager.contacts
        
        for correspondent in correspondents
        {
            if count(correspondent.name.utf16) > 20
            {
                var find = false
                for contact in contacts
                {
                    let emails: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonEmailProperty).takeUnretainedValue()  as ABMultiValueRef
                    let count  :Int = ABMultiValueGetCount(emails)
                    
                    if count > 0
                    {
                        for var index:CFIndex = 0; index < count; ++index
                        {
                            var lable  = ABMultiValueCopyLabelAtIndex(emails, index)
                            if lable != nil
                            {
                                if lable.takeUnretainedValue()  == "NEM"
                                {
                                    var value :String = ABMultiValueCopyValueAtIndex(emails, index).takeUnretainedValue() as! String
                                    if value == correspondent.name
                                    {
                                        if ABRecordCopyValue(contact, kABPersonFirstNameProperty) != nil
                                        {
                                            correspondent.name = (ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString as! String) + " "
                                        }
                                        
                                        if ABRecordCopyValue(contact, kABPersonLastNameProperty) != nil
                                        {
                                             correspondent.name =  correspondent.name +  ((ABRecordCopyValue(contact, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)! as! String)
                                        }
                                        
                                        find = true
                                    }
                                }
                            }
                            
                            if find
                            {
                                break
                            }
                        }
                    }
                    
                    if find
                    {
                        break
                    }
                }
            }
            
            dataManager.commit()
        }
    }
    
    final func refreshTransactionList()
    {
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var publicKey = KeyGenerator().generatePublicKey(privateKey)
        var account_address = AddressGenerator().generateAddress(publicKey)
        
        self.key.text = account_address
        
        if State.currentServer != nil
        {
            apiManager.accountGet(State.currentServer!, account_address: account_address)
            apiManager.accountTransfersAll(State.currentServer!, account_address: account_address)
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
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
    
    final func unconfirmedTransactionsSuccessed(notification: NSNotification)
    {
        unconfirmedTransactions +=  notification.object as! [TransactionPostMetaData]
        
        state.append("unconfirmedTransactionsSuccessed")
    }
    
    final func unconfirmedTransactionsDenied(notification: NSNotification)
    {
        state.append("unconfirmedTransactionsAllDenied")
    }
    
    final func accountTransfersAllSuccessed(notification: NSNotification)
    {
        var data :[TransactionPostMetaData] = notification.object as! [TransactionPostMetaData]
        
        for inData in data
        {
            switch (inData.type)
            {
            case transferTransaction :
                dataManager.addTransaction(inData as! TransferTransaction)
                
            case multisigTransaction:
                
                var multisigT  = inData as! MultisigTransaction
                
                switch(multisigT.innerTransaction.type)
                {
                case transferTransaction :
                    dataManager.addTransaction(multisigT.innerTransaction as! TransferTransaction)
                    
                default:
                    break
                }
                
            default:
                break
            }
        }
      
        state.append("accountTransfersAllSuccessed")
    }
    
    final func accountTransfersAllDenied(notification: NSNotification)
    {
        state.append("accountTransfersAllDenied")
    }
    
    final func getLastMessage(messages :[Transaction])-> Transaction?
    {
        if messages.count > 0
        {
            var message :Transaction = messages.first!
            
            for messageIN in messages
            {
                if (messageIN.id.integerValue > message.id.integerValue)
                {
                    message = messageIN
                }
            }
            
            return message
        }
        else
        {
            return nil
        }
    }
    
    final func sortCorrespondents(correspondents :[Correspondent])->[Correspondent]
    {
        var correspondentsIn = correspondents
        var data :[CorrespondentCellData] = [CorrespondentCellData]()
        
        for correspondent in correspondentsIn
        {
            var value = CorrespondentCellData()
            value.correspondent = correspondent
            value.lastMessage = getLastMessage(correspondent.transactions.allObjects as! [Transaction])
            data.append(value)
        }
        
        for var index = 0 ; index < data.count ; index++
        {
            var sorted = true
            
            for var indexIN = 0 ; indexIN < data.count - 1 ; indexIN++
            {
                var firstValue :Int!
                if data[indexIN].lastMessage != nil
                {
                    firstValue = data[indexIN].lastMessage!.id.integerValue
                }
                else
                {
                    firstValue = -1
                }
                
                var secondValue :Int!
                if data[indexIN + 1].lastMessage != nil
                {
                    secondValue = data[indexIN + 1].lastMessage!.id.integerValue
                }
                else
                {
                    secondValue = -1
                }
                
                if firstValue < secondValue || (secondValue == -1 &&  secondValue != firstValue)
                {
                    var accum = data[indexIN + 1]
                    data[indexIN + 1] = data[indexIN]
                    data[indexIN] = accum
                    
                    sorted = false
                }
            }
            
            if sorted
            {
                break
            }
        }
        
        correspondentsIn.removeAll(keepCapacity: false)
        
        for correspondent in data
        {
            correspondentsIn.append(correspondent.correspondent)
        }
        
        return correspondentsIn
    }

    override func viewDidAppear(animated: Bool)
    {
        tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
        
        displayList = correspondents
        
        tableView.reloadData()
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar)
    {
        resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == ""
        {
            displayList = correspondents
        }
        else
        {
            var predicate :NSPredicate = NSPredicate(format: "SELF.name contains[c] %@",searchText)
            displayList = (correspondents as NSArray).filteredArrayUsingPredicate(predicate)
        }
        
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool
    {
        return false
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            println("delete")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return displayList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : MessageCell = self.tableView.dequeueReusableCellWithIdentifier("correspondent") as! MessageCell
        var cellData  : Correspondent = displayList[indexPath.row] as! Correspondent
        var messages :[Transaction] = cellData.transactions.allObjects as! [Transaction]
        
        cell.name.text = "  " + cellData.name
        
        if messages.count > 0
        {
            var message :Transaction? = getLastMessage(messages)
            if message != nil
            {
                cell.message.text = message!.message_payload
            }
            else
            {
                cell.message.text = ""
            }
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var timeStamp = Double(message!.timeStamp )
            var block = dataManager.getBlock(Double(message!.height))
            
            if block != nil
            {
                timeStamp += Double(block!.timeStamp) / 1000
            }
            else
            {
                println("Error")
            }
            
            timeStamp += genesis_block_time

            cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
        }
        else
        {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        State.currentContact = correspondents[indexPath.row] as Correspondent
        if walletData != nil
        {
            State.invoice = nil
            
            if walletData.cosignatories.count == 0
            {
                State.toVC = SegueToMessageVC
            }
            else
            {
                State.toVC = SegueToMessageMultisignVC
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
        }
        else
        {
            self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }
    
    final func getNameWithAddress(name :String) -> String
    {
        return name
    }
    
    @IBAction func showKeyboard(sender: AnyObject)
    {
        showKeyboard = true
    }
    
    @IBAction func inputAddress(sender: UITextField)
    {
        if sender.text != ""
        {
            var find :Bool = false
            
            for correspondetn in correspondents
            {
                if correspondetn.public_key == sender.text
                {
                    State.currentContact = correspondetn as Correspondent
                    State.toVC = SegueToMessageVC
                    
                    find = true
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
                }
            }
            
            if !find
            {
                State.currentContact = dataManager.addCorrespondent(sender.text, name: sender.text , address : sender.text ,owner: State.currentWallet!)
                State.toVC = SegueToMessageVC
                
                NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
            }
        }
    }

    @IBAction func addressBook(sender: AnyObject)
    {
        if AddressBookManager.isAllowed
        {
            State.toVC = SegueToMessages
            
            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToAddressBook )        }
        else
        {
            var alert :UIAlertView = UIAlertView(title: "Info", message: "Contacts is unavailable.\nTo allow contacts follow to this directory\nSettings -> Privacy -> Contacts.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    func keyboardWillShow(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.25
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, -keyboardHeight, self.view.bounds.width, self.view.bounds.height)
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            
            
            var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
            
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, (self.view.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
                    
                }, completion: nil)
        }
    }
}
