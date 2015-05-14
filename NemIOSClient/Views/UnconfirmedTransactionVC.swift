import UIKit

class UnconfirmedTransactionVC: UIViewController ,UITableViewDelegate
{
    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    @IBOutlet weak var tableView: UITableView!
    
    var state :[String] = ["none"]
    var timer :NSTimer!
    var walletData :AccountGetMetaData!
    var selectedIndex = -1
    var unconfirmedTransactions  :[TransactionPostMetaData] = [TransactionPostMetaData]()
    var apiManager :APIManager = APIManager()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToUnconfirmedTransactionVC
        {
            State.fromVC = SegueToUnconfirmedTransactionVC
        }
        
        State.currentVC = SegueToUnconfirmedTransactionVC
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
        
        observer.addObserver(self, selector: "confirmCellWithTag:", name: "confirmCellWithTag", object: nil)
        observer.addObserver(self, selector: "showCellWithTag:", name: "showCellWithTag", object: nil)
        
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        
        observer.addObserver(self, selector: "prepareAnnounceSuccessed:", name: "prepareAnnounceSuccessed", object: nil)
        observer.addObserver(self, selector: "prepareAnnounceDenied:", name: "prepareAnnounceDenied", object: nil)
        
        observer.addObserver(self, selector: "unconfirmedTransactionsDenied:", name: "unconfirmedTransactionsDenied", object: nil)
        observer.addObserver(self, selector: "unconfirmedTransactionsSuccessed:", name: "unconfirmedTransactionsSuccessed", object: nil)
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var publicKey = KeyGenerator().generatePublicKey(privateKey)
        var account_address = AddressGenerator().generateAddress(publicKey)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        if State.currentServer != nil
        {
            apiManager.accountGet(State.currentServer!, account_address: account_address)
            apiManager.accountTransfersAll(State.currentServer!, account_address: account_address)
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }


    }

    final func manageState()
    {
        switch (state.last!)
        {
        case "accountGetSuccessed" :
            if walletData.cosignatoryOf.count > 0
            {
                unconfirmedTransactions.removeAll(keepCapacity: false)
                
                for cosignatory in walletData.cosignatoryOf
                {
                    APIManager().unconfirmedTransactions(State.currentServer!, account_address: cosignatory.address)
                }
            }
            
            state.removeLast()
            
        case "unconfirmedTransactionsSuccessed" :
            tableView.reloadData()
            
            state.removeLast()
            
        case "confirmCellWithTag" :
            
            var transaction :MultisigTransaction = unconfirmedTransactions[selectedIndex] as! MultisigTransaction
            
            switch (transaction.innerTransaction.type)
            {
            case transferTransaction:
                
                var sendTrans :MultisigSignatureTransaction = MultisigSignatureTransaction()
                sendTrans.transactionHash = unconfirmedTransactions[selectedIndex].data
                var innerTrans :TransferTransaction = transaction.innerTransaction as! TransferTransaction
                sendTrans.multisigAccountAddress = AddressGenerator().generateAddress(innerTrans.signer)
                
                sendTrans.timeStamp = Double(Int(TimeSynchronizator.nemTime))
                sendTrans.fee = 6
                sendTrans.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
                sendTrans.version = 1
                sendTrans.signer = walletData.publicKey

                APIManager().prepareAnnounce(State.currentServer!, transaction: sendTrans)
                
            case multisigAggregateModificationTransaction:
                
                var sendTrans :MultisigSignatureTransaction = MultisigSignatureTransaction()
                sendTrans.transactionHash = unconfirmedTransactions[selectedIndex].data
                var innerTrans :AggregateModificationTransaction = transaction.innerTransaction as! AggregateModificationTransaction
                sendTrans.multisigAccountAddress = AddressGenerator().generateAddress(innerTrans.signer)
                
                sendTrans.timeStamp = Double(Int(TimeSynchronizator.nemTime))
                sendTrans.fee = 6
                sendTrans.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
                sendTrans.version = 1
                sendTrans.signer = walletData.publicKey
                
                APIManager().prepareAnnounce(State.currentServer!, transaction: sendTrans)

            default :
                break
            }
            
            state.removeLast()
            
        case "showCellWithTag" :
            
            var text :String = "Account : "
            
            var transaction :AggregateModificationTransaction = (unconfirmedTransactions[selectedIndex] as! MultisigTransaction).innerTransaction as! AggregateModificationTransaction
            
            text += AddressGenerator().generateAddress(transaction.signer) + "\n"
            
            for modification in transaction.modifications
            {
                if modification.modificationType == 1
                {
                    text += "Add :\n"
                    text += modification.publicKey + "\n"
                }
                else
                {
                    text += "Delete :\n"
                    text += modification.publicKey + "\n"
                }
            }
            
            var alert :UIAlertController = UIAlertController(title: "Info", message: text, preferredStyle: UIAlertControllerStyle.Alert)
            
            var ok :UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive)
            {
                alertAction -> Void in
            }
            
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
            state.removeLast()
            
        case "prepareAnnounceSuccessed" :
            state.removeLast()
            if(selectedIndex > -1 && selectedIndex < unconfirmedTransactions.count )
            {
                unconfirmedTransactions.removeAtIndex(selectedIndex)
                if unconfirmedTransactions.count == 0
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:State.lastVC )
                }
                else
                {
                    tableView.reloadData()
                }
                selectedIndex = -1
            }
            
        case "prepareAnnounceDenied" :
            state.removeLast()
            
        default :
            break
        }
    }
    
    final func accountGetSuccessed(notification: NSNotification)
    {
        state.append("accountGetSuccessed")
        
        walletData = (notification.object as! AccountGetMetaData)
    }
    
    final func accountGetDenied(notification: NSNotification)
    {
        state.append("accountGetDenied")
    }
    
    final func confirmCellWithTag(notification: NSNotification)
    {
        state.append("confirmCellWithTag")
        selectedIndex = notification.object as! Int
        
    }
    
    final func prepareAnnounceSuccessed(notification: NSNotification)
    {
        state.append("prepareAnnounceSuccessed")
        
    }
    
    final func prepareAnnounceDenied(notification: NSNotification)
    {
        state.append("prepareAnnounceDenied")
    }
    
    final func showCellWithTag(notification: NSNotification)
    {
        state.append("showCellWithTag")
        selectedIndex = notification.object as! Int
    }
    
    final func unconfirmedTransactionsSuccessed(notification: NSNotification)
    {
        unconfirmedTransactions +=  notification.object as! [TransactionPostMetaData]
        var publicKey = KeyGenerator().generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
        
        for var i = 0 ; i < unconfirmedTransactions.count ; i++
        {
            if unconfirmedTransactions[i].type != multisigTransaction
            {
                unconfirmedTransactions.removeAtIndex(i)
            }
            else
            {
                var transaction :MultisigTransaction = unconfirmedTransactions[i] as! MultisigTransaction
                
                for sign in transaction.signatures
                {
                    if publicKey == sign.signer
                    {
                        unconfirmedTransactions.removeAtIndex(i)
                        break
                    }
                }
            }
        }
        
        state.append("unconfirmedTransactionsSuccessed")
    }
    
    final func unconfirmedTransactionsDenied(notification: NSNotification)
    {
        state.append("unconfirmedTransactionsAllDenied")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return unconfirmedTransactions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var transaction :MultisigTransaction = unconfirmedTransactions[indexPath.row] as! MultisigTransaction
        
        switch (transaction.innerTransaction.type)
        {
        case transferTransaction:
            var cell : UnconfirmedTransactionCell = self.tableView.dequeueReusableCellWithIdentifier("transferTransaction") as! UnconfirmedTransactionCell
            cell.fromAccount.text = AddressGenerator().generateAddress(((transaction.innerTransaction) as! TransferTransaction).signer)
            cell.toAccount.text = ((transaction.innerTransaction) as! TransferTransaction).recipient
            cell.message.text = ((transaction.innerTransaction) as! TransferTransaction).message.payload
            
            var format = ".0"
            cell.xem.text = "\((((transaction.innerTransaction) as! TransferTransaction).amount / 1000000).format(format)) XEM"
            
            cell.tag = indexPath.row
            
            return cell
            
        case multisigAggregateModificationTransaction:
            
            var innerTrnsaction :AggregateModificationTransaction = transaction.innerTransaction as! AggregateModificationTransaction
            var cell : UnconfirmedTransactionCell = self.tableView.dequeueReusableCellWithIdentifier("multisigAggregateModificationTransaction") as! UnconfirmedTransactionCell
            var format = ".0"
            
            cell.tag = indexPath.row
            cell.fromAccount.text = AddressGenerator().generateAddress(innerTrnsaction.signer)
            cell.toAccount.text = AddressGenerator().generateAddress(innerTrnsaction.signer)
            
            return cell
            
        default :
            break
        }
        return UITableViewCell()
    }
}
