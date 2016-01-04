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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToSendTransaction
        State.currentVC = SegueToSendTransaction
        
        _apiManager.delegate = self
        
        titleLabel.text = "NEW_TRANSACTION".localized()
        fromLabel.text = "FROM".localized() + ":"
        toLabel.text = "TO".localized() + ":"
        amountLabel.text = "AMOUNT".localized() + ":"
        messageLabel.text = "MESSAGE".localized() + ":"
        feeLabel.text = "FEE".localized() + ":"
        sendButton.setTitle("SEND", forState: UIControlState.Normal)
        
        toAddressTextField.placeholder = "ENTER_ADDRESS".localized()
        amountTextField.placeholder = "ENTER_AMOUNT".localized()
        messageTextField.placeholder = "EMPTY_MESSAGE".localized()
        feeTextField.placeholder = "ENTER_FEE".localized()
        
        let observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.currentWallet!.password)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
        
        if contact != nil {
            toAddressTextField.text = "\(contact!.address)"
        }
        
        if State.invoice != nil {
            invoice = State.invoice
            State.invoice = nil
            toAddressTextField.text = "\(invoice!.address)"
            amountTextField.text = "\(invoice!.amount)"
            messageTextField.text = "\(invoice!.message)"
            
            countTransactionFee()
            self.feeTextField.text = "\(transactionFee)"
        }
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
        self.feeTextField.text = "\(transactionFee)"
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
        self.feeTextField.text = "\(transactionFee)"
    }
    
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMessages)
        }
    }
    
    @IBAction func send(sender: AnyObject) {
        countTransactionFee()
        
        if Double(self.feeTextField.text!) < transactionFee {
            self.feeTextField.text = "\(transactionFee)"
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
            
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.currentWallet!.password)
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
        let transaction :TransferTransaction = TransferTransaction()
        
        transaction.timeStamp = Double(Int(TimeSynchronizator.nemTime))
        transaction.amount = Double(xems)
        transaction.message.payload = messageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!.asByteArray()
        transaction.message.type = MessageType.Normal.rawValue
        transaction.fee = transactionFee
        transaction.recipient = toAddressTextField.text!
        transaction.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
        transaction.version = 1
        transaction.signer = walletData.publicKey
        
        _apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
    }
    
    final func countTransactionFee() {
        
        self.xems = Double(amountTextField.text!) ?? 0
        self.amountTextField.text = "\(xems)"
        
        var newFee :Int = 0
        if xems >= 8 {
            newFee = Int(max(2, 99 * atan(xems / 150000)))
        }
        else {
            newFee = 10 - Int(xems)
        }
        let messageLength = messageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)?.asByteArray().count
        
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
        
        newFee = Int(max(newFee, Int(feeTextField.text!) ?? 0))
        
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
        self.feeTextField.text = "\(transactionFee)"
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
        walletData = account
        
        if _mainWallet == nil {
            if walletData.publicKey == nil {
                walletData.publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.currentWallet!.password)!)
            }
            
            _mainWallet = walletData
        }
        
        if account != nil {
            chooseButon.setTitle(walletData.address.nemName(), forState: UIControlState.Normal)
            
            let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "AMOUNT".localized() + " (" + "BALANCE".localized() + ": ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
            
            atributedText.appendAttributedString(NSMutableAttributedString(string: "\(walletData.balance / 1000000)", attributes: [
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
        chooseButon.setTitle(walletData.address.nemName(), forState: UIControlState.Normal)
        
        let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "AMOUNT".localized() + " (" + "BALANCE".localized() + ": ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
        
        atributedText.appendAttributedString(NSMutableAttributedString(string: "\(walletData.balance / 1000000)", attributes: [
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
