import UIKit

class SendTransactionVC: AbstractViewController, UIScrollViewDelegate, APIManagerDelegate, AccountsChousePopUpDelegate
{
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var toAddressTextField: NEMTextField!
    @IBOutlet weak var amountTextField: NEMTextField!
    @IBOutlet weak var messageTextField: NEMTextField!
    @IBOutlet weak var feeTextField: NEMTextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var chooseButon: ChouseButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var encButton: UIButton!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!

    @IBOutlet weak var sendButton: UIButton!
    
    private var _apiManager = APIManager()
    private var _mainWallet :AccountGetMetaData? = nil
    private var _popup :AbstractViewController? = nil
    
    var transactionFee :Double = 10;
    var walletData :AccountGetMetaData!
    var xems :Double = 0
    var invoice :InvoiceData? = nil
    var contact :Correspondent? = State.currentContact
    
    private var _isEnc = false
    private let greenColor :UIColor = UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)
    private let grayColor :UIColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
    private var _preparedTransaction :TransferTransaction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _apiManager.delegate = self
        
        titleLabel.text = "NEW_TRANSACTION".localized()
        fromLabel.text = "FROM".localized() + ":"
        toLabel.text = "TO".localized() + ":"
        amountLabel.text = "AMOUNT".localized() + ":"
        messageLabel.text = "MESSAGE".localized() + ":"
        feeLabel.text = "FEE".localized() + ":"
        sendButton.setTitle("SEND".localized(), forState: UIControlState.Normal)
        
        setSuggestions()

        toAddressTextField.placeholder = "ENTER_ADDRESS".localized()
        amountTextField.placeholder = "ENTER_AMOUNT".localized()
        messageTextField.placeholder = "EMPTY_MESSAGE".localized()
        feeTextField.placeholder = "ENTER_FEE".localized()
        
        let observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
        
        if contact != nil {
            toAddressTextField.text = "\(contact!.address)"
        }
        
        if State.invoice != nil {
            invoice = State.invoice
            State.invoice = nil
            toAddressTextField.text = "\(invoice!.address)"
            amountTextField.text = "\(invoice!.amount.format())"
            messageTextField.text = "\(invoice!.message)"
            
            countTransactionFee()
            self.feeTextField.text = "\(transactionFee.format())"
        }
    }
    
    final func setSuggestions() {
        var suggestions :[NEMTextField.Suggestion] = []
        
        let dataManager = CoreDataManager()
        for wallet in dataManager.getWallets() {
            let privateKey = HashManager.AES256Decrypt(wallet.privateKey, key: State.loadData!.password!)
            let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
            
            var find = false
            
            for suggestion in suggestions {
                if suggestion.key == account_address {
                    find = true
                    break
                }
            }
            if !find {
                var sugest = NEMTextField.Suggestion()
                sugest.key = account_address
                sugest.value = account_address
                suggestions.append(sugest)
            }
            
            find = false
            
            for suggestion in suggestions {
                if suggestion.key == wallet.login {
                    find = true
                    break
                }
            }
            if !find {
                var sugest = NEMTextField.Suggestion()
                sugest.key = wallet.login
                sugest.value = account_address
                suggestions.append(sugest)
            }
        }
        
        // TODO: Disable whole address book don't handle public keys
        
//        if AddressBookManager.isAllowed ?? false {
//            for contact in AddressBookManager.contacts {
//                var name = ""
//                if contact.givenName != "" {
//                    name = contact.givenName
//                }
//                
//                if contact.familyName != "" {
//                    name += " " + contact.familyName
//                }
//                
//                for email in contact.emailAddresses{
//                    if email.label == "NEM" {
//                        let account_address = email.value as? String ?? " "
//                        
//                        var find = false
//                        
//                        for suggestion in suggestions {
//                            if suggestion.key == account_address {
//                                find = true
//                                break
//                            }
//                        }
//                        if !find {
//                            var sugest = NEMTextField.Suggestion()
//                            sugest.key = account_address
//                            sugest.value = account_address
//                            suggestions.append(sugest)
//                        }
//                        
//                        find = false
//                        
//                        for suggestion in suggestions {
//                            if suggestion.key == name {
//                                find = true
//                                break
//                            }
//                        }
//                        if !find {
//                            var sugest = NEMTextField.Suggestion()
//                            sugest.key = name
//                            sugest.value = account_address
//                            suggestions.append(sugest)
//                        }
//                    }
//                }
//            }
//        }
        
        toAddressTextField.suggestions = suggestions
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        State.currentVC = SegueToSendTransaction
    }
    
    @IBAction func encTouchUpInside(sender: UIButton) {
        _preparedTransaction = nil
        _isEnc = !_isEnc
        sender.backgroundColor = (_isEnc) ? greenColor : grayColor
        countTransactionFee()
    }
    
    @IBAction func textFieldReturnKeyToched(sender: UITextField) {
        
        switch sender {
        case toAddressTextField :
            amountTextField.becomeFirstResponder()
        case amountTextField :
            messageTextField.becomeFirstResponder()
        case messageTextField :
            feeTextField.becomeFirstResponder()
        default :
            sender.becomeFirstResponder()
        }
        
        countTransactionFee()
        self.feeTextField.text = "\(transactionFee.format())"
    }
    
    @IBAction func textFieldEditingBegin(sender: NEMTextField) {
        switch sender {
        case amountTextField :
            var text = amountTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            text = amountTextField.text!.stringByReplacingOccurrencesOfString(",", withString: "")
            
            let amount = Double(text) ?? 0
            
            if amount < 0.000001  {
                amountTextField.text = ""
            }
            
        default :
            break
        }
    }

    @IBAction func textFieldEditingEnd(sender: UITextField) {
        switch sender {
        case amountTextField :
            countTransactionFee()
        case messageTextField :
            countTransactionFee()
            
        default :
            break
        }
        
        countTransactionFee()
        self.feeTextField.text = "\(transactionFee.format())"
    }
    
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMessages)
        }
    }
    
    @IBAction func send(sender: AnyObject) {
        let amount = Double(amountTextField.text!) ?? 0
        if amount < 0.000001 && amount != 0 {
            countTransactionFee()
            return
        } else {
            countTransactionFee()
        }
        
        if Double(self.feeTextField.text!) < transactionFee {
            self.feeTextField.text = "\(transactionFee.format())"
            return
        }
        
        if messageTextField.text?.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)?.asByteArray().count > 128 {
            _showPopUp("VALIDAATION_MESSAGE_LEANGTH".localized())
            return
        }
        
        if walletData != nil {
            var state = true
            toAddressTextField.text = toAddressTextField.text?.stringByReplacingOccurrencesOfString("-", withString: "")
            state = (state && Validate.stringNotEmpty(toAddressTextField.text))
            state = (state && (Validate.stringNotEmpty(messageTextField.text) || Validate.stringNotEmpty(amountTextField.text)))
            
            var findContent = Validate.stringNotEmpty(amountTextField.text)
            findContent = findContent && (amountTextField.text != "0")
            
            if !findContent {
                findContent = Validate.stringNotEmpty(messageTextField.text)
            }
            
            state = (state && Validate.stringNotEmpty(feeTextField.text))
            
            if state {
                if Int64(walletData.balance) >= Int64(xems) + Int64(transactionFee) {
                    _sendTransferTransaction()
                    
                    xems = 0;
                    messageTextField.text = ""
                    amountTextField.text = ""
                    feeTextField.text = ""
                } else {
                    _showPopUp("NOT_ENOUGHT_MONEY".localized())
                }
            } else {
                _showPopUp("FIELDS_EMPTY_ERROR".localized())
            }
            
        } else {
            _showPopUp("SERVER_UNAVAILABLE".localized())
            
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
            let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
            
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
    }
    
    private final func _showPopUp(message :String){
        
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default) {
            alertAction -> Void in
        }
        
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private final func _sendTransferTransaction() {
        
        let messageBytes :[UInt8] = messageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!.asByteArray()
        
        let transaction :TransferTransaction = TransferTransaction()
        
        transaction.timeStamp = Double(Int(TimeSynchronizator.nemTime))
        transaction.amount = Double(xems)
        transaction.message.payload = messageBytes
        transaction.message.type = (_isEnc) ? MessageType.Ecrypted.rawValue : MessageType.Normal.rawValue
        transaction.fee = transactionFee
        transaction.recipient = toAddressTextField.text!
        transaction.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
        transaction.version = 1
        transaction.signer = walletData.publicKey
        
        if _isEnc
        {
            _preparedTransaction = transaction
            
            _apiManager.accountGet(State.currentServer!, account_address: transaction.recipient)
        } else {
            if messageBytes.count > 160 {
                _showPopUp("VALIDAATION_MESSAGE_LEANGTH".localized())
                return
            }
            _apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
        }
    }
    
    final func countTransactionFee() {
        var text = amountTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        text = amountTextField.text!.stringByReplacingOccurrencesOfString(",", withString: "")
        
        var amount = Double(text) ?? 0

        if amount < 0.000001 && amount != 0 {
            amountTextField.text = "0"
            amount = 0
        }
        
        self.xems = amount
        self.amountTextField.text = "\(xems.format())".stringByReplacingOccurrencesOfString(" ", withString: "")
        
        var newFee :Int = 0
        
        if xems >= 8 {
            newFee = Int(max(2, 99 * atan(xems / 150000)))
        }
        else {
            newFee = 10 - Int(xems)
        }
        var messageLength = messageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)?.asByteArray().count
        
        if _isEnc && messageLength != 0{
            messageLength! += 64
        }
        
        if messageLength != 0 {
            newFee += Int(2 * max(1, Int( messageLength! / 16)))
        }
        
        let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "FEE".localized() +  ": (" + "MIN".localized() + " ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
        
        atributedText.appendAttributedString(NSMutableAttributedString(string: "\(Int(newFee))", attributes: [
            NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
            NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
            ]))
        
        atributedText.appendAttributedString(NSMutableAttributedString(string: " XEM)", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
        feeLabel.attributedText = atributedText
        
        let currentFee  = Int(feeTextField.text!) ?? 0
        
        newFee = Int(max(newFee, currentFee))
        
        transactionFee = Double(newFee)
        }
    
    @IBAction func endTyping(sender: NEMTextField) {
        
        if Int(amountTextField.text!) != nil {
            self.xems = Double(amountTextField.text!)!
        }
        else {
            self.xems = 0
        }
        
        countTransactionFee()
        self.feeTextField.text = "\(transactionFee.format())"
        sender.becomeFirstResponder()
    }
    
    @IBAction func chouseAccount(sender: AnyObject) {
        if _popup == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let accounts :AccountsChousePopUp =  storyboard.instantiateViewControllerWithIdentifier("AccountsChousePopUp") as! AccountsChousePopUp
            _popup = accounts
            accounts.view.frame = CGRect(origin: CGPoint(x: scroll.frame.origin.x, y: scroll.frame.origin.y + 5 ), size: scroll.frame.size)
            
            accounts.view.layer.opacity = 0
            accounts.delegate = self
            
            var wallets = _mainWallet?.cosignatoryOf ?? []
            
            if _mainWallet != nil
            {
                wallets.append(self._mainWallet!)
            }
            accounts.wallets = wallets
            
            if accounts.wallets.count > 0
            {
                self.contentView.addSubview(accounts.view)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    accounts.view.layer.opacity = 1
                    }, completion: nil)
            }
        } else {
            _popup!.view.removeFromSuperview()
            _popup!.removeFromParentViewController()
            _popup = nil
        }
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        
        if _preparedTransaction != nil && _preparedTransaction!.recipient == account?.address {
            guard let contactPublicKey = account?.publicKey else {
                _showPopUp("NO_PUBLIC_KEY_FOR_ENC".localized())
                return
            }
            
            var encryptedMessage :[UInt8] = Array(count: 32, repeatedValue: 0)
            encryptedMessage = MessageCrypto.encrypt(_preparedTransaction!.message.payload!, senderPrivateKey: HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!, recipientPublicKey: contactPublicKey)
            _preparedTransaction!.message.payload = encryptedMessage
            
            if encryptedMessage.count > 160 {
                _showPopUp("VALIDAATION_MESSAGE_LEANGTH".localized())
                return
            }
            _apiManager.prepareAnnounce(State.currentServer!, transaction: _preparedTransaction!)
            _preparedTransaction = nil
        }
        
        walletData = account
        
        if _mainWallet == nil {
            if walletData.publicKey == nil {
                walletData.publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!)
            }
            
            _mainWallet = walletData
        }
        
        if account != nil {
            if walletData.cosignatoryOf.count > 0 {
                chooseButon.hidden = false
                accountLabel.hidden = true
                chooseButon.setTitle(walletData.address.nemName(), forState: UIControlState.Normal)
            } else {
                chooseButon.hidden = true
                accountLabel.hidden = false
                accountLabel.text = walletData.address.nemName()
            }
            
            let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "AMOUNT".localized() + " (" + "BALANCE".localized() + ": ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
            
            atributedText.appendAttributedString(NSMutableAttributedString(string: "\((walletData.balance / 1000000).format())", attributes: [
                NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
                NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
                ]))
            
            atributedText.appendAttributedString(NSMutableAttributedString(string: " XEM):", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
            amountLabel.attributedText = atributedText
        } else {
            amountLabel.text = "AMOUNT".localized() + ":"
        }
    }
    
    func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
        
        var message :String = ""
        if (data ?? []).isEmpty {
            message = "TRANSACTION_ANOUNCE_FAILED".localized()
        } else {
            message = "TRANSACTION_ANOUNCE_SUCCESS".localized()
        }
        
        _showPopUp(message)
    }
    
    //MARK: - AccountsChousePopUpDelegate Methods
    
    func didChouseAccount(account: AccountGetMetaData) {
        walletData = account
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        encButton.enabled = walletData.address == account_address

        chooseButon.setTitle(walletData.address.nemName(), forState: UIControlState.Normal)
        
        let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "AMOUNT".localized() + " (" + "BALANCE".localized() + ": ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
        
        atributedText.appendAttributedString(NSMutableAttributedString(string: "\((walletData.balance / 1000000).format())", attributes: [
            NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
            NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
            ]))
        
        atributedText.appendAttributedString(NSMutableAttributedString(string: "XEM):", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
        amountLabel.attributedText = atributedText
    }
    
    //MARK: - KeyboardDelegate Methods
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight:CGFloat = keyboardSize.height - 60
        
        self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
