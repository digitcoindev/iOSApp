import UIKit

class SendTransactionVC: AbstractViewController, UIScrollViewDelegate, APIManagerDelegate, AccountsChousePopUpDelegate
{
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var toAddressTextField: NEMTextField!
    @IBOutlet weak var amountTextField: NEMTextField!
    @IBOutlet weak var messageTextField: NEMTextField!
    @IBOutlet weak var feeTextField: NEMTextField!
    @IBOutlet weak var amountLabel: UILabel!
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
    
    var state :[String] = ["none"]
    
    var timer :NSTimer!
    var showRect :CGRect = CGRectZero
    
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
        
        if State.currentServer != nil {
            _apiManager.accountGet(State.currentServer!, account_address: account_address)
        }
        
        if State.invoice != nil {
            toAddressTextField.text = "\(invoice!.address)"
            amountTextField.text = "\(invoice!.amount)"
            messageTextField.text = "\(invoice!.message)"
            
            countTransactionFee()
        }
    }

    @IBAction func touchDown(sender: AnyObject) {
        showRect = sender.frame
    }
    
    @IBAction func addXEMs(sender: AnyObject) {
        if Int((sender as! UITextField).text!) != nil {
            self.xems = Int((sender as! UITextField).text!)!
        }
        else {
            self.xems = 0
        }
        
        countTransactionFee()
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    @IBAction func send(sender: AnyObject) {
        if walletData != nil {
            if Int64(walletData.balance) > Int64(xems) {
                if (messageTextField.text != "" || xems != 0 ) {
                    
                    _sendTransferTransaction()
                    
                    xems = 0;
                    messageTextField.text = ""
                    amountTextField.text = ""
                    feeTextField.text = ""
                }
            }
            else {
                let alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: "Not enough money", preferredStyle: UIAlertControllerStyle.Alert)
                
                let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive)
                    {
                        alertAction -> Void in
                }
                
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
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
        if xems >= 8 {
            transactionFee = max(2, 99 * atan(Double(xems) / 150000))
        }
        else {
            transactionFee = 10 - Double(xems)
        }
        
        if messageTextField.text!.utf16.count != 0 {
            transactionFee += Double(2 * max(1, Int( messageTextField.text!.utf16.count / 16)))
        }
        
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
        
        let alert :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            alertAction -> Void in
        }
        
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
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
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height - 20
        
        self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.scroll.scrollRectToVisible(showRect, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
