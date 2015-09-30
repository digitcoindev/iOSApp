import UIKit

class SendTransactionVC: AbstractViewController ,UIScrollViewDelegate
{
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var InputMessage: NEMTextField!
    @IBOutlet weak var InputAmound: NEMTextField!
    @IBOutlet weak var walletBalance: UILabel!
    @IBOutlet weak var correspondentAddress: UILabel!
    @IBOutlet weak var chooseWalletButton: ButtonDropDown!
    @IBOutlet weak var transactionFeeLable: UILabel!
    
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
        
        if State.fromVC != SegueToSendTransaction {
            State.fromVC = SegueToSendTransaction
        }
        
        State.currentVC = SegueToSendTransaction
        
        
        let observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "prepareAnnounceSuccessed:", name: "prepareAnnounceSuccessed", object: nil)
        observer.addObserver(self, selector: "prepareAnnounceDenied:", name: "prepareAnnounceDenied", object: nil)
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        observer.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        observer.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        observer.postNotificationName("Title", object:"Create transaction" )
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        
        if State.currentServer != nil {
            APIManager().accountGet(State.currentServer!, account_address: account_address)
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }
        
        if State.invoice != nil {
            InputAmound.text = "\(invoice!.amount)"
            InputMessage.text = "\(invoice!.message)"
            
            countTransactionFee()
        }
        
        correspondentAddress.text = contact!.address
        walletBalance.text = ""
        transactionFeeLable.text = ""

        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    final func manageState() {
        switch (state.last!) {
        case "accountGetSuccessed" :
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
            let publicKey = KeyGenerator.generatePublicKey(privateKey)
            
            if publicKey == walletData.publicKey {
                var content :[String] = [String]()
                var contentActions :[funcBlock] = [funcBlock]()
                let accountAddress :String = self.walletData.address
                content.append("This account")
                contentActions.append( {
                    () -> () in
                
                    if State.currentServer != nil
                    {
                        APIManager().accountGet(State.currentServer!, account_address: accountAddress)
                    }
                })
                
                for account in walletData.cosignatoryOf {
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
                
                chooseWalletButton.setContent(content, contentActions: contentActions)
                
            }

            let format = ".0"
            walletBalance.text = "\((walletData.balance / 1000000).format(format)) XEM"
            state.removeLast()
            
        case "prepareAnnounceSuccessed" :
            state.removeLast()
            let alert1 :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: "SUCCESS", preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    alertAction -> Void in
            }
            
            alert1.addAction(ok)
            self.presentViewController(alert1, animated: true, completion: nil)
            
        case "prepareAnnounceDenied" :
            state.removeLast()
            let alert1 :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message: "DENIED\nTry again later. Or check connection to server.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    alertAction -> Void in
            }
            
            alert1.addAction(ok)
            self.presentViewController(alert1, animated: true, completion: nil)
            
        default :
            break
        }
    }

    final func accountGetSuccessed(notification: NSNotification) {
        state.append("accountGetSuccessed")
        
        walletData = (notification.object as! AccountGetMetaData)
    }
    
    final func accountGetDenied(notification: NSNotification) {
        state.append("accountGetDenied")
    }
    
    final func prepareAnnounceSuccessed(notification: NSNotification) {
        let json = notification.object as! NSDictionary
        let message :String = json.objectForKey("message") as! String
        if message == "SUCCESS" {
            state.append("prepareAnnounceSuccessed")
        }
        else {
            state.append("prepareAnnounceDenied")
        }
    }
    
    final func prepareAnnounceDenied(notification: NSNotification) {
        state.append("prepareAnnounceDenied")
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
    
    @IBAction func send(sender: AnyObject) {
        if walletData != nil {
            if Int64(walletData.balance) > Int64(xems) {
                if (InputMessage.text != "" || xems != 0 ) && State.currentServer != nil {
                    let transaction :TransferTransaction = TransferTransaction()
                    
                    transaction.timeStamp = Double(Int(TimeSynchronizator.nemTime))
                    transaction.amount = Double(xems)
                    transaction.message.payload = InputMessage.text!
                    transaction.fee = transactionFee 
                    transaction.recipient = contact!.address
                    transaction.type = 257
                    transaction.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
                    transaction.message.type = 1
                    transaction.version = 1
                    transaction.signer = walletData.publicKey
                    
                    APIManager().prepareAnnounce(State.currentServer!, transaction: transaction)
                    
                    xems = 0;
                    InputMessage.text = ""
                    InputAmound.text = ""
                    transactionFeeLable.text = ""
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
    
    final func countTransactionFee() {
        if xems >= 8 {
            transactionFee = max(2, 99 * atan(Double(xems) / 150000))
        }
        else {
            transactionFee = 10 - Double(xems)
        }
        
        if InputMessage.text!.utf16.count != 0 {
            transactionFee += Double(2 * max(1, Int( InputMessage.text!.utf16.count / 16)))
        }
        
        self.transactionFeeLable.text = "\(Int64(transactionFee)) XEM"
    }
    
    @IBAction func typing(sender: NEMTextField) {
        countTransactionFee()
    }
    
    @IBAction func closeKeyboard(sender: UITextField) {
        sender.becomeFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
                
        keyboardHeight -= self.view.frame.height - self.scroll.frame.height
        
        self.scroll.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight , 0)
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.scroll.scrollRectToVisible(showRect, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.scroll.contentInset = UIEdgeInsetsZero
        self.scroll.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}
