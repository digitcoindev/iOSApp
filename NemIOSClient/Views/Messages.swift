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
    var currentBalance :Double = 0
    
    var apiManager :APIManager = APIManager()
    var correspondents :[Correspondent]!
    var displayList :NSArray = NSArray()
    var searchBar : UISearchBar!
    var searchText :String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToMessages
        {
            State.fromVC = SegueToMessages
        }

        State.currentVC = SegueToMessages
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
        
        address.layer.cornerRadius = 2
        tableView.layer.cornerRadius = 2
        searchBar = UISearchBar(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 44)))
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        searchBar.showsCancelButton = true
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: false)

        correspondents = State.currentWallet!.correspondents.allObjects as! [Correspondent]
        displayList = correspondents

        findCorrespondentName()
        refreshTransactionList()
        
        if (State.currentContact != nil && State.toVC == SegueToPasswordValidation )
        {
            State.toVC = SegueToMessageVC
            
            observer.postNotificationName("DashboardPage", object:SegueToPasswordValidation )
        }
        
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        observer.addObserver(self, selector: "accountTransfersAllDenied:", name: "accountTransfersAllDenied", object: nil)
        observer.addObserver(self, selector: "accountTransfersAllSuccessed:", name: "accountTransfersAllSuccessed", object: nil)
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    final func manageState()
    {
        switch (state.last!)
        {
        case "accountTransfersAllSuccessed" :
            correspondents = State.currentWallet!.correspondents.allObjects as! [Correspondent]
            displayList = correspondents
            tableView.reloadData()
            state.removeLast()
            
        case "accountGetSuccessed" :
            var format = ".0"
            self.balance.text = "\(currentBalance.format(format))"
            State.currentWallet!.balance = currentBalance
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
                                        if var name = ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString
                                        {
                                            correspondent.name = (name as! String) + " "
                                        }
                                        
                                        if var surname = ABRecordCopyValue(contact, kABPersonLastNameProperty).takeUnretainedValue() as? NSString
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
        
        apiManager.accountGet(State.currentServer!, account_address: account_address)
        apiManager.accountTransfersAll(State.currentServer!, account_address: account_address)
    }
    
    final func accountGetSuccessed(notification: NSNotification)
    {
        state.append("accountGetSuccessed")
       
        currentBalance = (notification.object as! AccountGetMetaData).balance
    }
    
    final func accountGetDenied(notification: NSNotification)
    {
        state.append("accountGetDenied")
        
        self.balance.text = "Null"
        State.currentWallet!.balance = 0
    }
    
    final func accountTransfersAllSuccessed(notification: NSNotification)
    {
        var data :[TransactionPostMetaData] = notification.object as! [TransactionPostMetaData]
        
        for inData in data
        {
            if inData.type == transferTransaction
            {
                dataManager.addTransaction(inData)
            }
            else
            {
                println()
            }
        }
        state.append("accountTransfersAllSuccessed")
    }
    
    final func accountTransfersAllDenied(notification: NSNotification)
    {
        state.append("accountTransfersAllDenied")
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
            var message :Transaction!
            
            if messages.count > 0
            {
                message = messages[0]
            }
            
//            for mes  in messages
//            {
//                if mes.date.compare(message.date) == NSComparisonResult.OrderedDescending
//                {
//                    message = mes
//                }
//            }
            
            cell.message.text = message.message_payload
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var timeStamp = Double(message.timeStamp ) 
            var block = dataManager.getBlock(Double(message.height))
            
            timeStamp += Double(block.timeStamp) / 1000
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
        State.toVC = SegueToMessageVC
        
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
    }
    
    final func getNameWithAddress(name :String) -> String
    {
        
        
        return name
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
                State.currentContact = dataManager.addCorrespondent(sender.text, name: sender.text , address : sender.text)
                State.toVC = SegueToMessageVC
                
                NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
            }
        }
    }

    @IBAction func addressBook(sender: AnyObject)
    {
        State.toVC = SegueToMessages
                
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToAddressBook )
    }
    
    
    override func viewDidDisappear(animated: Bool)
    {
        
    }
}
