import UIKit

class UnconfirmedTransactionVC: AbstractViewController ,UITableViewDelegate, APIManagerDelegate
{
    @IBOutlet weak var tableView: UITableView!

    
    var walletData :AccountGetMetaData!
    var unconfirmedTransactions  :[TransactionPostMetaData] = [TransactionPostMetaData]()
    private var _apiManager :APIManager = APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToUnconfirmedTransactionVC
        
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let publicKey = KeyGenerator.generatePublicKey(privateKey!)
        let account_address = AddressGenerator.generateAddress(publicKey)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }

    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMessages)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return unconfirmedTransactions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let transaction :MultisigTransaction = unconfirmedTransactions[indexPath.row] as! MultisigTransaction
        
        switch (transaction.innerTransaction.type) {
        case transferTransaction:
            return 344
            
        case multisigAggregateModificationTransaction:
            return 267
            
        default :
            break
        }
        return 344
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let transaction :MultisigTransaction = unconfirmedTransactions[indexPath.row] as! MultisigTransaction
        
        switch (transaction.innerTransaction.type) {
        case transferTransaction:
            let innerTransaction = (transaction.innerTransaction) as! TransferTransaction
            let cell : UnconfirmedTransactionCell = self.tableView.dequeueReusableCellWithIdentifier("transferTransaction") as! UnconfirmedTransactionCell
            cell.fromAccount.text = AddressGenerator.generateAddress(innerTransaction.signer).nemName()
            cell.toAccount.text = innerTransaction.recipient.nemName()
            cell.message.text = innerTransaction.message.getMessageString() ?? "ENCRYPTED_MESSAGE".localized()
            cell.delegate = self
            cell.xem.text = "\(innerTransaction.amount / 1000000) XEM"
            
            cell.tag = indexPath.row
            
            return cell
            
        case multisigAggregateModificationTransaction:
            
            let innerTrnsaction :AggregateModificationTransaction = transaction.innerTransaction as! AggregateModificationTransaction
            let cell : UnconfirmedTransactionCell = self.tableView.dequeueReusableCellWithIdentifier("multisigAggregateModificationTransaction") as! UnconfirmedTransactionCell
            cell.delegate = self
            cell.tag = indexPath.row
            cell.fromAccount.text = AddressGenerator.generateAddress(innerTrnsaction.signer)
            cell.toAccount.text = AddressGenerator.generateAddress(innerTrnsaction.signer)
            
            return cell
            
        default :
            break
        }
        return UITableViewCell()
    }
    
    final func confirmTransactionAtIndex(index: Int){
        if unconfirmedTransactions.count > index {
            let transaction :MultisigTransaction = unconfirmedTransactions[index] as! MultisigTransaction
            
            switch (transaction.innerTransaction.type) {
            case transferTransaction:
                
                let sendTrans :MultisigSignatureTransaction = MultisigSignatureTransaction()
                sendTrans.transactionHash = unconfirmedTransactions[index].data
                let innerTrans :TransferTransaction = transaction.innerTransaction as! TransferTransaction
                sendTrans.multisigAccountAddress = AddressGenerator.generateAddress(innerTrans.signer)
                
                sendTrans.timeStamp = Double(Int(TimeSynchronizator.nemTime))
                sendTrans.fee = 6
                sendTrans.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
                sendTrans.version = 1
                sendTrans.signer = walletData.publicKey
                
                _apiManager.prepareAnnounce(State.currentServer!, transaction: sendTrans)
                
            case multisigAggregateModificationTransaction:
                
                let sendTrans :MultisigSignatureTransaction = MultisigSignatureTransaction()
                sendTrans.transactionHash = unconfirmedTransactions[index].data
                let innerTrans :AggregateModificationTransaction = transaction.innerTransaction as! AggregateModificationTransaction
                sendTrans.multisigAccountAddress = AddressGenerator.generateAddress(innerTrans.signer)
                
                sendTrans.timeStamp = Double(Int(TimeSynchronizator.nemTime))
                sendTrans.fee = 6
                sendTrans.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
                sendTrans.version = 1
                sendTrans.signer = walletData.publicKey
                
                _apiManager.prepareAnnounce(State.currentServer!, transaction: sendTrans)
                
            default :
                break
            }
        }
    }
    
    final func showTransactionAtIndex(index: Int){
        var text :String = "ACCOUNT".localized() + " : "
        
        let transaction :AggregateModificationTransaction = (unconfirmedTransactions[index] as! MultisigTransaction).innerTransaction as! AggregateModificationTransaction
        
        text += AddressGenerator.generateAddress(transaction.signer) + "\n"
        
        for modification in transaction.modifications {
            if modification.modificationType == 1 {
                text += "ADD" + " :\n"
                text += modification.publicKey + "\n"
            }
            else {
                text += "DELETE".localized() + " :\n"
                text += modification.publicKey + "\n"
            }
        }
        
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Destructive) {
            alertAction -> Void in
        }
        
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private final func _showPopUp(message :String){
        
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default) {
            alertAction -> Void in
            
        }
        
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - APIManagerDelegate Methods
    
    final func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        if let responceAccount = account {
            walletData = responceAccount
            
            if walletData.cosignatoryOf.count > 0 {
                unconfirmedTransactions.removeAll(keepCapacity: false)
                
                _apiManager.unconfirmedTransactions(State.currentServer!, account_address: walletData.address)
            }
        }
    }
    
    final func unconfirmedTransactionsResponceWithTransactions(data: [TransactionPostMetaData]?) {
        if let data = data {
            unconfirmedTransactions += data
            let publicKey = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!)
            
            for var i = 0 ; i < unconfirmedTransactions.count ; i++ {
                if unconfirmedTransactions[i].type != multisigTransaction {
                    unconfirmedTransactions.removeAtIndex(i)
                }
                else {
                    let transaction :MultisigTransaction = unconfirmedTransactions[i] as! MultisigTransaction
                    
                    if transaction.signer == walletData.publicKey{
                        unconfirmedTransactions.removeAtIndex(i)
                        i--
                        continue
                    }
                    
                    for sign in transaction.signatures {
                        if publicKey == sign.signer
                        {
                            unconfirmedTransactions.removeAtIndex(i)
                            i--
                            break
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
        
        var message :String = ""
        if (data ?? []).isEmpty {
            message = "TRANSACTION_ANOUNCE_FAILED".localized()
        } else {
            message = "TRANSACTION_ANOUNCE_SUCCESS".localized()
            
            if unconfirmedTransactions.count == 1 {
                backButtonTouchUpInside(self)
            } else {
                _apiManager.accountGet(State.currentServer!, account_address: walletData.address)
            }
        }
        
        _showPopUp(message)
    }
}
