import UIKit
import AddressBook

class Messages: AbstractViewController , UITableViewDelegate ,UISearchBarDelegate, APIManagerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInfo: NEMLabel!
    
    let dataManager : CoreDataManager = CoreDataManager()
    var walletData :AccountGetMetaData!
    
    private var _unconfirmedTransactions  :[TransactionPostMetaData] = [TransactionPostMetaData]()
    private var _apiManager :APIManager = APIManager()
    private var _correspondents :[Correspondent] = []
    
    private var _displayList :NSArray = NSArray()
    private var _searchBar : UISearchBar!
    private var _searchText :String = ""
    
    // MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToMessages
        State.currentVC = SegueToMessages
        
        tableView.layer.cornerRadius = 2
        _apiManager.delegate = self
        
        _searchBar = UISearchBar(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 44)))
        _searchBar.delegate = self
        tableView.tableHeaderView = _searchBar
        _searchBar.showsCancelButton = true
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.setContentOffset(CGPoint(x: 0, y: _searchBar.frame.height), animated: false)

        _displayList = _correspondents

        if AddressBookManager.isAllowed {
            findCorrespondentName()
        }
        
        refreshTransactionList()
        
        if (State.currentContact != nil && State.toVC == SegueToPasswordValidation ) {
            State.toVC = SegueToMessageVC
            
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToPasswordValidation)
            }
        }
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - APIManagerDelegate Methods
    
    final func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        if let responceAccount = account {
            walletData = responceAccount
            var userDescription :NSMutableAttributedString!
            
            if let wallet = State.currentWallet {
                userDescription = NSMutableAttributedString(string: "\(wallet.login)")
            }
            
            var format = ".0"
            var attribute = [NSForegroundColorAttributeName : UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)]
            var balance = " \((walletData.balance / 1000000).format(format)) XEM"
            
            userDescription.appendAttributedString(NSMutableAttributedString(string: balance, attributes: attribute))
            
            self.userInfo.attributedText = userDescription
            
            if walletData.cosignatoryOf.count > 0 {
                _unconfirmedTransactions.removeAll(keepCapacity: false)
                
                for cosignatory in walletData.cosignatoryOf {
                    _apiManager.unconfirmedTransactions(State.currentServer!, account_address: cosignatory.address)
                }
            }
            
        } else {
            self.userInfo.attributedText = NSMutableAttributedString(string: NSLocalizedString("LOST_CONNECTION", comment: "Title"), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
        }
    }

    final func accountTransfersAllResponceWithTransactions(data: [TransactionPostMetaData]?) {
        if let data = data {
            var transactions :[TransferTransaction] = []
            for inData in data {
                switch (inData.type) {
                case transferTransaction :
                    transactions.append(inData as! TransferTransaction)
                    
                case multisigTransaction:
                    
                    var multisigT  = inData as! MultisigTransaction
                    
                    switch(multisigT.innerTransaction.type) {
                    case transferTransaction :
                        transactions.append(multisigT.innerTransaction as! TransferTransaction)
                        
                    default:
                        break
                    }
                default:
                    break
                }
            }
            
            _correspondents = Correspondent.generateCorespondetsFromTransactions(transactions)
            _displayList = _correspondents
            
            tableView.reloadData()

        } else {
            self.userInfo.attributedText = NSMutableAttributedString(string: NSLocalizedString("LOST_CONNECTION", comment: "Title"), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
        }
    }
    
    final func unconfirmedTransactionsResponceWithTransactions(data: [TransactionPostMetaData]?) {
        if let data = data {
            var showAlert = (_unconfirmedTransactions.count == 0) ? true : false
            _unconfirmedTransactions += data
            
            var findUnconfirmed = false
            if showAlert {
                for inTransaction in _unconfirmedTransactions {
                    switch(inTransaction.type) {
                    case multisigTransaction:
                        var transaction :MultisigTransaction = inTransaction as! MultisigTransaction
                        var find = false
                        
                        for sign in transaction.signatures {
                            if walletData.publicKey == sign.signer {
                                find = true
                                break
                            }
                        }
                        
                        if inTransaction.signer != walletData.publicKey && !find {
                            var alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("UNCONFIRMED_TRANSACTIONS_DETECTED", comment: "Description"), preferredStyle: UIAlertControllerStyle.Alert)
                            
                            var ok :UIAlertAction = UIAlertAction(title: NSLocalizedString("SHOW_TRANSACTIONS", comment: "Title"), style: UIAlertActionStyle.Default) {
                                    alertAction -> Void in
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToUnconfirmedTransactionVC )
                                    
                            }
                            
                            var cancel :UIAlertAction = UIAlertAction(title: NSLocalizedString("REMIND_LATER", comment: "Title"), style: UIAlertActionStyle.Default) {
                                    alertAction -> Void in
                            }
                            
                            alert.addAction(cancel)
                            alert.addAction(ok)
                            
                            if !findUnconfirmed {
                                findUnconfirmed = true
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                        
                    default:
                        break
                    }
                    
                    if findUnconfirmed {
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - IBAction

    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    // MARK: - Help Methods
    
    final func sort_correspondents(_correspondents :[Correspondent])->[Correspondent] {
        var _correspondentsIn = _correspondents
        var data :[CorrespondentCellData] = [CorrespondentCellData]()
        
        for correspondent in _correspondentsIn {
            var value = CorrespondentCellData()
            value.correspondent = correspondent
            value.lastMessage = correspondent.transaction
            data.append(value)
        }
        
        for var index = 0 ; index < data.count ; index++ {
            var sorted = true
            
            for var indexIN = 0 ; indexIN < data.count - 1 ; indexIN++ {
                var firstValue :Int!
                if data[indexIN].lastMessage != nil {
                    firstValue = Int(data[indexIN].lastMessage!.id)
                }
                else {
                    firstValue = -1
                }
                
                var secondValue :Int!
                if data[indexIN + 1].lastMessage != nil {
                    secondValue = Int(data[indexIN + 1].lastMessage!.id)
                }
                else {
                    secondValue = -1
                }
                
                if firstValue < secondValue || (secondValue == -1 &&  secondValue != firstValue) {
                    var accum = data[indexIN + 1]
                    data[indexIN + 1] = data[indexIN]
                    data[indexIN] = accum
                    
                    sorted = false
                }
            }
            
            if sorted {
                break
            }
        }
        
        _correspondentsIn.removeAll(keepCapacity: false)
        
        for correspondent in data {
            _correspondentsIn.append(correspondent.correspondent)
        }
        
        return _correspondentsIn
    }
    
    final func findCorrespondentName() {
        var contacts :NSArray = AddressBookManager.contacts
        
        for correspondent in _correspondents {
            if count(correspondent.name.utf16) > 20 {
                var find = false
                for contact in contacts {
                    let emails: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonEmailProperty).takeUnretainedValue()  as ABMultiValueRef
                    let count  :Int = ABMultiValueGetCount(emails)
                    
                    if count > 0 {
                        for var index:CFIndex = 0; index < count; ++index {
                            var lable  = ABMultiValueCopyLabelAtIndex(emails, index)
                            if lable != nil {
                                if lable.takeUnretainedValue()  == "NEM" {
                                    var value :String = ABMultiValueCopyValueAtIndex(emails, index).takeUnretainedValue() as! String
                                    if value == correspondent.name {
                                        if ABRecordCopyValue(contact, kABPersonFirstNameProperty) != nil {
                                            correspondent.name = (ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString as! String) + " "
                                        }
                                        
                                        if ABRecordCopyValue(contact, kABPersonLastNameProperty) != nil {
                                            correspondent.name =  correspondent.name +  ((ABRecordCopyValue(contact, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)! as! String)
                                        }
                                        
                                        find = true
                                    }
                                }
                            }
                            
                            if find {
                                break
                            }
                        }
                    }
                    
                    if find {
                        break
                    }
                }
            }
            
            dataManager.commit()
        }
    }
    
    final func refreshTransactionList() {
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var publicKey = KeyGenerator.generatePublicKey(privateKey)
        var account_address = AddressGenerator.generateAddress(publicKey)
        
        if State.currentServer != nil {
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
            _apiManager.accountTransfersAll(State.currentServer!, account_address: account_address)
        }
        else {
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToServerTable)
            }
        }
    }
    
    // MARK: - Search Bar Data Sourse
    
    func _searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
        
        _displayList = _correspondents
        
        tableView.reloadData()
        _searchBar.resignFirstResponder()
    }
    
    func _searchBarSearchButtonClicked(searchBar: UISearchBar) {
        _searchBar.showsCancelButton = true
    }
    
    func _searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        resignFirstResponder()
    }
    
    func _searchBar(searchBar: UISearchBar, textDidChange _searchText: String) {
        if _searchText == "" {
            _displayList = _correspondents
        }
        else {
            var predicate :NSPredicate = NSPredicate(format: "SELF.name contains[c] %@",_searchText)
            _displayList = (_correspondents as NSArray).filteredArrayUsingPredicate(predicate)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Sourse
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            println("delete")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _displayList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : MessageCell = self.tableView.dequeueReusableCellWithIdentifier("correspondent") as! MessageCell
        var cellData  : Correspondent = _displayList[indexPath.row] as! Correspondent
        var transaction :TransferTransaction? = cellData.transaction
        
        cell.name.text = "  " + cellData.name
        
        if transaction != nil {
            
            cell.message.text = MessageCrypto.getMessageStringFrom(transaction!.message)
        }
        else {
            cell.message.text = ""
        }
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var timeStamp = Double(transaction!.timeStamp )
        
        timeStamp += genesis_block_time
        
        if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp)) == dateFormatter.stringFromDate(NSDate()) {
            dateFormatter.dateFormat = "HH:mm:ss"
        }
        
        cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        var color :UIColor!
        var vector :String = ""
        if transaction?.recipient != account_address {
            color = UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)
            vector = "+"
        } else {
            color = UIColor.redColor()
            vector = "-"
        }
        
        var attribute = [NSForegroundColorAttributeName : color]
        
        var format = ".0"
        var amount = vector + "\((transaction!.amount / 1000000).format(format)) XEM"
        
        cell.xems.attributedText = NSMutableAttributedString(string: amount, attributes: attribute)
                
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        State.currentContact = _correspondents[indexPath.row] as Correspondent
        if walletData != nil {
            State.invoice = nil
            
            if walletData.cosignatories.count == 0 {
                State.toVC = SegueToMessageVC
            }
            else {
                State.toVC = SegueToMessageMultisignVC
            }
            
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToPasswordValidation)
            }
        }
        else {
            self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }
}
