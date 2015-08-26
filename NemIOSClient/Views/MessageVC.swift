import UIKit

struct DefinedCell
{
    var type :String = ""
    var height :CGFloat = 44
}

class MessageVC: AbstractViewController, UITableViewDelegate, UIAlertViewDelegate, APIManagerDelegate, AccountsChousePopUpDelegate 
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInfo: NEMLabel!
    @IBOutlet weak var amoundField: NEMTextField!
    @IBOutlet weak var messageField: NEMTextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var accountsButton: UIButton!
    @IBOutlet weak var amoundContainerView: UIView!
    @IBOutlet weak var contactInfo: UILabel!
    
    private var _unconfirmedTransactions  :[TransferTransaction] = []
    private var _apiManager :APIManager = APIManager()
    private var _operationDipatchQueue :dispatch_queue_t = dispatch_queue_create("Message VC operation queu", nil)
    private var _definedCells :[DefinedCell] = []
    private var _transactions  :[TransferTransaction] = []
    
    private var _isHex = false
    private var _isEnc = false
    
    var walletData :AccountGetMetaData!
    
    let dataManager :CoreDataManager = CoreDataManager()
    let contact :Correspondent = State.currentContact!

    let rowLength :Int = 21
    let textSizeCommon :CGFloat = 12
    let textSizeXEM :CGFloat = 14
    
    // MARK: - Load Methods

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
        
        contactInfo.text = contact.name
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        scrollToEnd()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {

        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - IBAction

    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }

    @IBAction func amoundFieldDidEndOnExit(sender: UITextField) {
        if sender.text.toInt() == nil {
            sender.text = "0"
        }
    }
    
    @IBAction func messageFieldDidEndOnExit(sender: UITextField) {
        if sender.text.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)?.asByteArray().count > 255 {
            sender.text = ""
        }
    }
    
    @IBAction func hexTouchUpInside(sender: UIButton) {
        _isHex = !_isHex
        sender.backgroundColor = (_isHex) ? UIColor(red: 65 / 255, green: 206 / 255, blue: 123 / 255, alpha: 1) :
                                            UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
        
    }
    
    @IBAction func encTouchUpInside(sender: UIButton) {
        _isEnc = !_isEnc
        sender.backgroundColor = (_isEnc) ? UIColor(red: 65 / 255, green: 206 / 255, blue: 123 / 255, alpha: 1) :
            UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
    }
    
    @IBAction func accountsButtonDidTouchInside(sender: AnyObject){
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var accounts :AccountsChousePopUp =  storyboard.instantiateViewControllerWithIdentifier("AccountsChousePopUp") as! AccountsChousePopUp
        
        accounts.view.frame = CGRect(x: tableView.frame.origin.x + 10,
            y:  tableView.frame.origin.y + 10,
            width: tableView.frame.width - 20,
            height: tableView.frame.height - 20)
        
        accounts.view.layer.opacity = 0
        accounts.delegate = self
        
        accounts.wallets = walletData.cosignatoryOf
        
        self.view.addSubview(accounts.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            accounts.view.layer.opacity = 1
            }, completion: nil)

    }
    
    @IBAction func sendButtonTouchUpInside(sender: AnyObject) {
        
        if walletData == nil || State.currentServer == nil {
            return
        }
        
        var transaction :TransferTransaction = TransferTransaction()
        
        if let amount = amoundField.text.toInt() {
            if Int64(walletData.balance) > Int64(amount) {
                transaction.amount = Double(amount)
            } else {
                var alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("ACCOUNT_NOT_ENOUGHT_MONEY", comment: "Description") , preferredStyle: UIAlertControllerStyle.Alert)
                
                var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) {
                    alertAction -> Void in
                }
                
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
        } else {
            amoundField.text = "0"
            transaction.amount = 0
            return
        }
        
        //TODO: Encrypted Messages
        
        if messageField.text.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)?.asByteArray().count < 255 {
            var text = (_isHex) ? "fe" + messageField.text : messageField.text.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)
            
            if !Validate.hexString(text!) {
                var alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("NOT_A_HEX_STRING", comment: "Descripton") , preferredStyle: UIAlertControllerStyle.Alert)
                
                var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive) {
                    alertAction -> Void in
                }
                
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
                
                return

            }
            
            text = (_isEnc) ? text : text
            
            transaction.message.payload = text!
            transaction.message.type = (_isEnc) ? 2 : 1
            
        } else {
            messageField.text = ""
            return
        }
        
        var fee = 0.0
        
        if transaction.amount >= 8 {
            fee = max(2, 99 * atan(transaction.amount / 150000))
        }
        else {
            fee = 10 - transaction.amount
        }
        
        if count(messageField.text.utf16) != 0 {
            fee += Double(2 * max(1, Int( count(messageField.text.utf16) / 16)))
        }
        
        transaction.timeStamp = Double(Int(TimeSynchronizator.nemTime))
        transaction.fee = fee
        transaction.recipient = contact.address
        transaction.type = 257
        transaction.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
        transaction.version = 1
        transaction.signer = walletData.publicKey
        
        _apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
        
        messageField.text = ""
        amoundField.text = ""
    }
    
    // MARK: - Helper Methods
    
    func setString(message :String)->CGFloat {
        var numberOfRows :Int = 0
        for component :String in message.componentsSeparatedByString("\n") {
            numberOfRows += 1
            numberOfRows += count(component) / rowLength
        }
        
        var height : Int = numberOfRows * 17
        
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
        for(var index = 0; index < _transactions.count; index++) {
            var sorted = true
            
            for(var index = 0; index < _transactions.count - 1; index++) {
                var height :Double!
                
                var valueA :Double = Double((_transactions[index] as TransferTransaction).id)
                
                var valueB :Double = Double((_transactions[index + 1] as TransferTransaction).id)
                
                if valueA > valueB {
                    sorted = false
                    accum = _transactions[index]
                    _transactions[index] = _transactions[index + 1]
                    _transactions[index + 1] = accum
                }
            }
            
            if sorted {
                break
            }
        }
    }
    
    final func defineData() {
        var publicKey :String = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
        var data :[DefinedCell] = []
        for transaction in _transactions {
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

            data.append(definedCell)
        }
        
        for transaction in _unconfirmedTransactions {
            var definedCell : DefinedCell = DefinedCell()
            definedCell.type = "unconfirmedCell"
            
            var height :CGFloat = heightForView(transaction.message.payload, font: UIFont(name: "HelveticaNeue", size: textSizeCommon)!, width: tableView.frame.width - 60)
            
            if  transaction.amount != 0 {
                height += heightForView("\n \(Int(Double(transaction.amount) / 1000000) )" , font: UIFont(name: "HelveticaNeue", size: textSizeXEM)!, width: tableView.frame.width - 60)
            }
            
            definedCell.height =  height
            
            data.append(definedCell)
        }
        
        _definedCells = data
    }
    
    func scrollToEnd() {
        var indexPath :NSIndexPath!
        
            if (tableView.numberOfRowsInSection(0) != 0) {
                indexPath = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1 , inSection: 0)
            }
        
        if indexPath != nil {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _definedCells.count > 0 {
            var count = _transactions.count + 1
            count += (_unconfirmedTransactions.count > 0) ? _unconfirmedTransactions.count + 1 : 0
            return count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if( !(indexPath.row == 0) ) {
            var index :Int = 0
            var cell : CustomMessageCell!
            
            if indexPath.row <= _transactions.count {
                index = indexPath.row - 1
                cell = self.tableView.dequeueReusableCellWithIdentifier(_definedCells[index].type) as! CustomMessageCell
                
                var transaction = _transactions[index]
                var messageText = MessageCrypto.getMessageStringFrom(transaction.message)
                
                messageText = (messageText == nil) ? "" : messageText
                
                var message :NSMutableAttributedString = NSMutableAttributedString(string: messageText! , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: textSizeCommon)!])
                
                if(Int(_transactions[index].amount) != 0) {
                    var text :String = "\(Int(_transactions[index].amount / 1000000) ) XEM"
                    if _transactions[index].message.payload != ""
                    {
                        text = "\n" + text
                    }
                    
                    var messageXEMS :NSMutableAttributedString = NSMutableAttributedString(string:text , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeXEM)! ])
                    message.appendAttributedString(messageXEMS)
                }
                message = (message.length == 0) ? NSMutableAttributedString(string:NSLocalizedString("EMPTY_MESSAGE", comment: "Description") , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Italic", size: textSizeCommon)! ]) : message
                var messageDate :NSMutableAttributedString = NSMutableAttributedString(string:"\n" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeCommon)! ])
                message.appendAttributedString(messageDate)
                
                cell.message.attributedText = message
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm dd.MM.yy "
                
                var timeStamp = Double(_transactions[index].timeStamp)
                
                cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: genesis_block_time + timeStamp))
                
                if(indexPath.row == _transactions.count ) {
                    NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
                }
                
                cell.message.layer.cornerRadius = 5
                cell.message.layer.masksToBounds = true
                
                return cell
            } else {
            
                index = indexPath.row - _transactions.count - 2
                
                if index < 0 {
                    var headerCell :UITableViewCell  = self.tableView.dequeueReusableCellWithIdentifier("groupHeader") as! UITableViewCell
                    return headerCell
                }
                
                cell = self.tableView.dequeueReusableCellWithIdentifier(_definedCells[index + _transactions.count].type) as! CustomMessageCell
                
                var transaction :TransferTransaction = _unconfirmedTransactions[index]
                
                var messageText = MessageCrypto.getMessageStringFrom(transaction.message)
                messageText = (messageText == nil) ? "" : messageText
                
                var message :NSMutableAttributedString = NSMutableAttributedString(string: messageText!, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeCommon)!])
                
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
            }
        }
        
        var cell :UITableViewCell  = self.tableView.dequeueReusableCellWithIdentifier("simpl") as! UITableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
        } else if indexPath.row <= _transactions.count + 1  {
            
            return _definedCells[indexPath.row - 1].height
        } else if indexPath.row == _transactions.count + 1 {
            return 44
        } else {
            return _definedCells[indexPath.row - 2].height
        }
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
                
                self._apiManager.unconfirmedTransactions(State.currentServer!, account_address: self.walletData.address)
                
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
                var _transactions :[TransferTransaction] = []
                for inData in data {
                    switch (inData.type) {
                    case transferTransaction :
                        _transactions.append(inData as! TransferTransaction)
                        
                    case multisigTransaction:
                        
                        var multisigT  = inData as! MultisigTransaction
                        
                        switch(multisigT.innerTransaction.type) {
                        case transferTransaction :
                            _transactions.append(multisigT.innerTransaction as! TransferTransaction)
                            
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
                
                for var index = 0; index < _transactions.count; index++ {
                    var needToSave = false
                    if AddressGenerator.generateAddress(_transactions[index].signer) == self.walletData.address && _transactions[index].recipient == self.contact.address {
                        needToSave = true
                    }
                    
                    if AddressGenerator.generateAddress(_transactions[index].signer) == self.contact.address && _transactions[index].recipient == self.walletData.address {
                        needToSave = true
                    }
                    
                    if !needToSave {
                        _transactions.removeAtIndex(index)
                        index--
                    }
                }
                
                self._transactions = _transactions
                
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
    
    func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
        if data != nil || data?.count > 0 {
            var alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message:  NSLocalizedString("TRANSACTION_ANOUNCE_SUCCESS", comment: "Description"), preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                alertAction -> Void in
            }
            
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            var alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("TRANSACTION_ANOUNCE_FAILED", comment: "Description"), preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                alertAction -> Void in
            }
            
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - AccountsChousePopUpDelegate Methods

    func didChouseAccount(account: AccountGetMetaData) {
        walletData = account
        
        var userDescription :NSMutableAttributedString!
        
        if let wallet = State.currentWallet {
            userDescription = NSMutableAttributedString(string: "\(walletData.address)")
        }
        
        var format = ".0"
        var attribute = [NSForegroundColorAttributeName : UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)]
        var balance = " \((self.walletData.balance / 1000000).format(format)) XEM"
        
        userDescription.appendAttributedString(NSMutableAttributedString(string: balance, attributes: attribute))
        
        dispatch_async(dispatch_get_main_queue() , {
            () -> Void in
            self.userInfo.attributedText = userDescription
        })
    }
    
    //MARK: - Keyboard Methods
    
    func keyboardWillShow(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var height:CGFloat = keyboardSize.height - 65
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - height)

            }, completion: { (successed :Bool) -> Void in })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var height:CGFloat = keyboardSize.height - 65
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + height)

            }, completion: { (successed :Bool) -> Void in })
    }
    
}
