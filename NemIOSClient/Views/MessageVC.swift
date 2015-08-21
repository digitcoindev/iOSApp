import UIKit

struct DefinedCell
{
    var type :String = ""
    var height :CGFloat = 44
}

class MessageVC: AbstractViewController, UITableViewDelegate, UIAlertViewDelegate, APIManagerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInfo: NEMLabel!
    @IBOutlet weak var amoundField: NEMTextField!
    @IBOutlet weak var messageField: NEMTextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var accountsButton: UIButton!
    @IBOutlet weak var amoundContainerView: UIView!
    
    private var _unconfirmedTransactions  :[TransferTransaction] = []
    private var _apiManager :APIManager = APIManager()
    private var _operationDipatchQueue :dispatch_queue_t = dispatch_queue_create("Message VC operation queu", nil)
    private var _definedCells :[DefinedCell] = []
    
    var transactionFee :Double = 10;
    var walletData :AccountGetMetaData!
    
    let dataManager :CoreDataManager = CoreDataManager()
    let contact :Correspondent = State.currentContact!
    
    var transactions  :[TransferTransaction]!
    
    var rowLength :Int = 21
    let textSizeCommon :CGFloat = 12
    let textSizeXEM :CGFloat = 14
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToMessageVC
        State.currentVC = SegueToMessageVC
        
        _apiManager.delegate = self

        if accountsButton != nil {
            accountsButton.layer.cornerRadius = 5
        }
        
        if sendButton != nil {
            sendButton.layer.cornerRadius = 5
        }
        
        if amoundContainerView != nil {
            amoundContainerView.layer.cornerRadius = 5
            amoundContainerView.clipsToBounds = true
        }
        
        if messageField != nil {
            messageField.layer.cornerRadius = 5
        }
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        
        if State.currentServer != nil {
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
        else {
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToServerTable)
            }
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        scrollToEnd()
        
        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createTransaction(sender: AnyObject) {
        State.invoice = nil
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToSendTransaction )
    }
    
    func  numberOfSectionsInTableView(UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _definedCells.count > 0 {
            switch (section) {
            case 0:
                return transactions.count + 1
                
            case 1:
                return _unconfirmedTransactions.count
                
            default:
                break
            }
        }
        
        return 0
    }
    
    func setString(message :String)->CGFloat {
        var numberOfRows :Int = 0
        for component :String in message.componentsSeparatedByString("\n") {
            numberOfRows += 1
            numberOfRows += count(component) / rowLength
        }
        
        var height : Int = numberOfRows  * 17
        
        return CGFloat(height)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func sortMessages() {
        var accum :TransferTransaction!
        for(var index = 0; index < transactions.count; index++) {
            var sorted = true
            
            for(var index = 0; index < transactions.count - 1; index++) {
                var height :Double!
                
                var valueA :Double = Double((transactions[index] as TransferTransaction).id)
                
                var valueB :Double = Double((transactions[index + 1] as TransferTransaction).id)
                
                if valueA > valueB {
                    sorted = false
                    accum = transactions[index]
                    transactions[index] = transactions[index + 1]
                    transactions[index + 1] = accum
                }
            }
            
            if sorted {
                break
            }
        }
    }
    
    final func defineData() {
        var publicKey :String = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
        for transaction in transactions {
            var definedCell : DefinedCell = DefinedCell()
            definedCell.type = "inCell"
            
            if (transaction.signer == publicKey) {
                definedCell.type = "outCell"
            }
            
            
            for cosignatory in walletData.cosignatories {
                if cosignatory.publicKey == transaction.signer {
                    definedCell.type = "outCell"
                    break
                }
            }
            
            for cosignatory in walletData.cosignatoryOf {
                if cosignatory.publicKey == transaction.signer {
                    definedCell.type = "outCell"
                    break
                }
            }
            var text = MessageCrypto.getMessageStringFrom(transaction.message)
            text = (text == nil) ? "" : text
            var height :CGFloat = heightForView(text!, font: UIFont(name: "HelveticaNeue-Light", size: textSizeCommon)!, width: tableView.frame.width - 120)
            
            if  Int(transaction.amount) != 0 {
                height += heightForView("\n \(Int(Double(transaction.amount) / 1000000))" , font: UIFont(name: "HelveticaNeue", size: textSizeXEM)!, width: tableView.frame.width - 120)
            } else {
                height += 30
            }
    
            definedCell.height =  height

            _definedCells.append(definedCell)
        }
        
        for transaction in _unconfirmedTransactions {
            var definedCell : DefinedCell = DefinedCell()
            definedCell.type = "unconfirmedCell"
            
            var height :CGFloat = heightForView(transaction.message.payload, font: UIFont(name: "HelveticaNeue", size: textSizeCommon)!, width: tableView.frame.width - 60)
            
            if  transaction.amount != 0 {
                height += heightForView("\n \(Int(Double(transaction.amount) / 1000000) )" , font: UIFont(name: "HelveticaNeue", size: textSizeXEM)!, width: tableView.frame.width - 60)
            }
            
            definedCell.height =  height
            
            _definedCells.append(definedCell)
        }
        self.tableView.reloadData()
    }
    
    func scrollToEnd() {
        var indexPath1 :NSIndexPath!
        
        if(tableView.numberOfRowsInSection(1) == 0) {
            if (tableView.numberOfRowsInSection(0) != 0) {
                indexPath1 = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1 , inSection: 0)
            }
        }
        else {
            indexPath1 = NSIndexPath(forRow: tableView.numberOfRowsInSection(1) - 1 , inSection: 1)
        }
        
        if indexPath1 != nil {
            tableView.scrollToRowAtIndexPath(indexPath1, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView,titleForHeaderInSection section: Int) -> String {
        switch section {
        case 1:
            return "unconfirmed transactions"
            
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if( !(indexPath.row == 0 && indexPath.section == 0) ) {
            var index :Int = 0
            var cell : CustomMessageCell!
            
            switch (indexPath.section) {
            case 0:
                index = indexPath.row - 1
                cell = self.tableView.dequeueReusableCellWithIdentifier(_definedCells[index].type) as! CustomMessageCell
                
                var transaction = transactions[index]
                var messageText = MessageCrypto.getMessageStringFrom(transaction.message)
                
                messageText = (messageText == nil) ? "" : messageText
                
                var message :NSMutableAttributedString = NSMutableAttributedString(string: messageText! , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: textSizeCommon)!])
                
                if(Int(transactions[index].amount) != 0) {
                    var text :String = "\(Int(transactions[index].amount / 1000000) ) XEM"
                    if transactions[index].message.payload != ""
                    {
                        text = "\n" + text
                    }
                    
                    var messageXEMS :NSMutableAttributedString = NSMutableAttributedString(string:text , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeXEM)! ])
                    message.appendAttributedString(messageXEMS)
                }
                message = (message.length == 0) ? NSMutableAttributedString(string:"Empty message" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Italic", size: textSizeCommon)! ]) : message
                var messageDate :NSMutableAttributedString = NSMutableAttributedString(string:"\n" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeCommon)! ])
                message.appendAttributedString(messageDate)
                
                cell.message.attributedText = message
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm dd.MM.yy "
                
                var timeStamp = Double(transactions[index].timeStamp)
                
                cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: genesis_block_time + timeStamp))
                
                if(indexPath.row == transactions.count ) {
                    NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
                }
                
                cell.message.layer.cornerRadius = 5
                cell.message.layer.masksToBounds = true
                
                return cell
                
            case 1:
                index = indexPath.row
                cell = self.tableView.dequeueReusableCellWithIdentifier(_definedCells[index + transactions.count].type) as! CustomMessageCell
                
                var transaction :TransferTransaction = _unconfirmedTransactions[index]
                var message :NSMutableAttributedString = NSMutableAttributedString(string: transaction.message.payload , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeCommon)!])
                
                if(transaction.amount  != 0) {
                    var text :String = "\(Int(Double(transaction.amount) / 1000000) ) XEM"
                    if transaction.message.payload != ""
                    {
                        text = "\n" + text
                    }
                    
                    var messageXEMS :NSMutableAttributedString = NSMutableAttributedString(string:text , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: textSizeXEM)! ])
                    message.appendAttributedString(messageXEMS)
                }
                
                cell.message.attributedText = message
                cell.message.layer.cornerRadius = 5
                cell.message.layer.masksToBounds = true
                
                return cell
                
            default :
                break
            }
        }
        
        var cell    :UITableViewCell  = self.tableView.dequeueReusableCellWithIdentifier("simpl") as! UITableViewCell
        return cell as UITableViewCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section) {
        case 0:
            if indexPath.row == 0 {
                var height :CGFloat = 0
                
                for cell in _definedCells {
                    height += cell.height
                }
                
                if height >= self.tableView.bounds.height {
                    return 1
                }
                else {
                    return self.tableView.bounds.height - height
                }
            }
            else {
                return _definedCells[indexPath.row - 1].height
            }
            
        case 1:
            if transactions.count  > 0 {
                return _definedCells[indexPath.row + transactions.count - 1].height
            }
            else {
                return _definedCells[indexPath.row ].height
            }
            
        default:
            break
        }
        
        return 1
    }

    // MARK: - APIManagerDelegate Methods
    
    final func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        dispatch_async(_operationDipatchQueue, {
            () -> Void in
            if let responceAccount = account {
                self.walletData = responceAccount
                var userDescription :NSMutableAttributedString!
                
                if let wallet = State.currentWallet {
                    userDescription = NSMutableAttributedString(string: "\(wallet.login)")
                }
                
                var format = ".0"
                var attribute = [NSForegroundColorAttributeName : UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)]
                var balance = " \((self.walletData.balance / 1000000).format(format)) XEM"
                
                userDescription.appendAttributedString(NSMutableAttributedString(string: balance, attributes: attribute))
                
                dispatch_async(dispatch_get_main_queue() , {
                    () -> Void in
                    self.userInfo.attributedText = userDescription
                })
                
                if self.walletData.cosignatoryOf.count > 0 {
                    self._unconfirmedTransactions.removeAll(keepCapacity: false)
                    
                    for cosignatory in self.walletData.cosignatoryOf {
                        self._apiManager.unconfirmedTransactions(State.currentServer!, account_address: cosignatory.address)
                    }
                }
                
                self._apiManager.accountTransfersAll(State.currentServer!, account_address: self.walletData.address)
                
            } else {
                dispatch_async(dispatch_get_main_queue() , {
                    () -> Void in
                    self.userInfo.attributedText = NSMutableAttributedString(string: NSLocalizedString("LOST_CONNECTION", comment: "Title"), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
                })
            }
        })
    }
    
    final func accountTransfersAllResponceWithTransactions(data: [TransactionPostMetaData]?) {
        dispatch_async(_operationDipatchQueue, {
            () -> Void in
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
                
                for var index = 0; index < transactions.count; index++ {
                    var needToSave = false
                    if AddressGenerator.generateAddress(transactions[index].signer) == self.walletData.address && transactions[index].recipient == self.contact.address {
                        needToSave = true
                    }
                    
                    if AddressGenerator.generateAddress(transactions[index].signer) == self.contact.address && transactions[index].recipient == self.walletData.address {
                        needToSave = true
                    }
                    
                    if !needToSave {
                        transactions.removeAtIndex(index)
                        index--
                    }
                }
                
                self.transactions = transactions
                
                self.sortMessages()
                
                self._definedCells.removeAll(keepCapacity: false)
                self.defineData()
                
                dispatch_async(dispatch_get_main_queue() , {
                    () -> Void in
                    self.tableView.reloadData()
                    self.scrollToEnd()
                })
                
            } else {
                dispatch_async(dispatch_get_main_queue() , {
                    () -> Void in
                    self.userInfo.attributedText = NSMutableAttributedString(string: NSLocalizedString("LOST_CONNECTION", comment: "Title"), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
                })
            }
        })
    }
    
    final func unconfirmedTransactionsResponceWithTransactions(data: [TransactionPostMetaData]?) {
        dispatch_async(_operationDipatchQueue, {
            () -> Void in
            
            if let data = data {
                var unconfirmedTransactions :[TransferTransaction] = []
                for transaction in data {
                    switch (transaction.type) {
                    case transferTransaction :
                        unconfirmedTransactions.append(transaction as! TransferTransaction)
                        
                    case multisigTransaction:
                        
                        var multisigT  = transaction as! MultisigTransaction
                        
                        switch(multisigT.innerTransaction.type) {
                        case transferTransaction :
                            var innerTransaction = multisigT.innerTransaction as! TransferTransaction
                            unconfirmedTransactions.append(innerTransaction)
                            
                        default:
                            break
                        }
                        
                    default:
                        break
                    }
                }
                
                var address :String = self.contact.address
                
                for var index = 0  ; index < unconfirmedTransactions.count ; index++ {
                    if unconfirmedTransactions[index].recipient != address {
                        unconfirmedTransactions.removeAtIndex(index)
                        index--
                    }
                }
                
                self._unconfirmedTransactions += unconfirmedTransactions
                
                self._definedCells.removeAll(keepCapacity: false)
                self.defineData()
                
                dispatch_async(dispatch_get_main_queue() , {
                    () -> Void in
                    self.tableView.reloadData()
                    self.scrollToEnd()
                })
            } else {
                dispatch_async(dispatch_get_main_queue() , {
                    () -> Void in
                    self.userInfo.attributedText = NSMutableAttributedString(string: NSLocalizedString("LOST_CONNECTION", comment: "Title"), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
                })
            }
        })
    }
    
    //MARK: - Keyboard Methods
    
    func keyboardWillShow(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: keyboardHeight, width: self.view.frame.width, height: self.view.frame.height - keyboardHeight)

            }, completion: { (successed :Bool) -> Void in })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + keyboardHeight)
            
            }, completion: { (successed :Bool) -> Void in })
    }
    
}
