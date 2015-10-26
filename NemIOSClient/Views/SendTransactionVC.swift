import UIKit

class SendTransactionVC: AbstractViewController, UIScrollViewDelegate, APIManagerDelegate, AccountsChousePopUpDelegate
{
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var toAddressTextField: NEMTextField!
    @IBOutlet weak var amountTextField: NEMTextField!
    @IBOutlet weak var messageTextField: NEMTextField!
    @IBOutlet weak var feeTextField: NEMTextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var chooseButon: ChouseButton!
    
    private var _apiManager = APIManager()
    private var _mainWallet :AccountGetMetaData? = nil
    private var _popup :AbstractViewController? = nil
    
    var transactionFee :Double = 10;
    var walletData :AccountGetMetaData!
    var xems :Int = 0
    let invoice :InvoiceData? = State.invoice
    var contact :Correspondent? = State.currentContact
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToSendTransaction
        State.currentVC = SegueToSendTransaction
        
        _apiManager.delegate = self
        
        let observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
        
        if contact != nil {
            toAddressTextField.text = "\(contact!.address)"
        }
        
        if State.invoice != nil {
            toAddressTextField.text = "\(invoice!.address)"
            amountTextField.text = "\(invoice!.amount)"
            messageTextField.text = "\(invoice!.message)"
            
            countTransactionFee()
        }
    }
    
    @IBAction func textFieldReturnKeyToched(sender: UITextField) {
        
        switch sender {
        case toAddressTextField :
            amountTextField.becomeFirstResponder()
        case amountTextField :
            messageTextField.becomeFirstResponder()
            countTransactionFee()
        case messageTextField :
            feeTextField.becomeFirstResponder()
            countTransactionFee()
            
        default :
            sender.becomeFirstResponder()
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
    }
    
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    @IBAction func send(sender: AnyObject) {
        countTransactionFee()
        if walletData != nil {
            var state = true
            
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
                    _showPopUp(NSLocalizedString("NOT_ENOUGHT_MONEY", comment: "Dsecription"))
                }
            } else {
                _showPopUp(NSLocalizedString("FIELDS_EMPTY_ERROR", comment: "Dsecription"))
            }
            
        } else {
            _showPopUp(NSLocalizedString("SERVER_UNAVAILABLE", comment: "Dsecription"))
            
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
            let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
            
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
    }
    
    private final func _showPopUp(message :String){
        
        let alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            alertAction -> Void in
        }
        
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private final func _sendTransferTransaction() {
        let transaction :TransferTransaction = TransferTransaction()
        
        transaction.timeStamp = Double(Int(TimeSynchronizator.nemTime))
        transaction.amount = Double(xems)
        transaction.message.payload = messageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!
        transaction.message.type = Double(MessageType.Normal.rawValue)
        transaction.fee = transactionFee
        transaction.recipient = toAddressTextField.text!
        transaction.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
        transaction.version = 1
        transaction.signer = walletData.publicKey
        
        _apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
    }
    
    final func countTransactionFee() {
        
        self.xems = Int(amountTextField.text!) ?? 0
        self.amountTextField.text = "\(xems)"
        
        var newFee :Double = 0
        if xems >= 8 {
            newFee = max(2, 99 * atan(Double(xems) / 150000))
        }
        else {
            newFee = 10 - Double(xems)
        }
        
        if messageTextField.text!.utf16.count != 0 {
            newFee += Double(2 * max(1, Int( messageTextField.text!.utf16.count / 16)))
        }
        
        let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "Fee: (Min ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
        
        let format = ".0"
        atributedText.appendAttributedString(NSMutableAttributedString(string: "\(newFee.format(format))", attributes: [
            NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
            NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
            ]))
        
        atributedText.appendAttributedString(NSMutableAttributedString(string: " XEM)", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
        feeLabel.attributedText = atributedText
        
        newFee = max(newFee, Double(feeTextField.text!) ?? 0)
        
        transactionFee = newFee
        
        self.feeTextField.text = "\(Int64(transactionFee))"
    }
    
    @IBAction func endTyping(sender: NEMTextField) {
        
        if Int(amountTextField.text!) != nil {
            self.xems = Int(amountTextField.text!)!
        }
        else {
            self.xems = 0
        }
        
        countTransactionFee()
        sender.becomeFirstResponder()
    }
    
    @IBAction func chouseAccount(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let accounts :AccountsChousePopUp =  storyboard.instantiateViewControllerWithIdentifier("AccountsChousePopUp") as! AccountsChousePopUp
        
        accounts.view.frame = scroll.frame
        
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
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        walletData = account
        
        if _mainWallet == nil {
            if walletData.publicKey == nil {
                walletData.publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
            }
            
            _mainWallet = walletData
        }
        
        if account != nil {
            chooseButon.setTitle(walletData.address, forState: UIControlState.Normal)
            
            let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "Amount (Current Balance: ", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
            
            let format = ".0"
            atributedText.appendAttributedString(NSMutableAttributedString(string: "\((walletData.balance / 1000000).format(format))", attributes: [
                NSForegroundColorAttributeName : UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1),
                NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16)!
                ]))
            
            atributedText.appendAttributedString(NSMutableAttributedString(string: " XEM):", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!]))
            amountLabel.attributedText = atributedText
        } else {
            amountLabel.text = "Amount:"
        }
    }
    
    func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
        
        var message :String = ""
        if (data ?? []).isEmpty {
            message = NSLocalizedString("TRANSACTION_ANOUNCE_FAILED", comment: "Dsecription")
        } else {
            message = NSLocalizedString("TRANSACTION_ANOUNCE_SUCCESS", comment: "Description")
        }
        
        _showPopUp(message)
    }
    
    //MARK: - AccountsChousePopUpDelegate Methods
    
    func didChouseAccount(account: AccountGetMetaData) {
        walletData = account
        chooseButon.setTitle(walletData.address, forState: UIControlState.Normal)
        
        let atributedText :NSMutableAttributedString = NSMutableAttributedString(string: "Amount (Current Balance:", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 17)!])
        
        let format = ".0"
        atributedText.appendAttributedString(NSMutableAttributedString(string: "\((walletData.balance / 1000000).format(format))", attributes: [
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
