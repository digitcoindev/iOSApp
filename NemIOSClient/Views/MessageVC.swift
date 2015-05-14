import UIKit

struct DefinedCell
{
    var type :String = ""
    var height :CGFloat = 44
}

class MessageVC: UIViewController , UITableViewDelegate , UIAlertViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balance: UILabel!
    
    var transactionFee :Double = 10;
    var walletData :AccountGetMetaData!

    let dataManager :CoreDataManager = CoreDataManager()
    let contact :Correspondent = State.currentContact!
    
    var transactions  :[Transaction]!
    var unconfirmedTransactions  :[TransferTransaction] = [TransferTransaction]()
    var definedCells :[DefinedCell] = [DefinedCell]()
    
    var state :[String] = ["none"]
    
    var timer :NSTimer!
    
    var rowLength :Int = 21
    let textSizeCommon :CGFloat = 12
    let textSizeXEM :CGFloat = 14

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToMessageVC
        {
            State.fromVC = SegueToMessageVC
        }
        
        State.currentVC = SegueToMessageVC

        transactions = contact.transactions.allObjects as! [Transaction]
        
        sortMessages()
        
        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "unconfirmedTransactionsDenied:", name: "unconfirmedTransactionsDenied", object: nil)
        observer.addObserver(self, selector: "unconfirmedTransactionsSuccessed:", name: "unconfirmedTransactionsSuccessed", object: nil)
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        observer.addObserver(self, selector: "scrollToEnd:", name: "scrollToEnd", object: nil)
        
        observer.postNotificationName("Title", object:State.currentContact!.name )
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var account_address = AddressGenerator().generateAddressFromPrivateKey(privateKey)
        
        if State.currentServer != nil
        {
            APIManager().accountGet(State.currentServer!, account_address: account_address)
            APIManager().unconfirmedTransactions(State.currentServer!, account_address: account_address)
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        observer.postNotificationName("scrollToEnd", object:nil )
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
    }
    

    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    final func manageState()
    {
        switch (state.last!)
        {
        case "accountGetSuccessed" :
            var format = ".0"
            
            balance.text = " Balance : \((walletData.balance / 1000000).format(format)) XEM"
            state.removeLast()
            
            
        case "unconfirmedTransactionsSuccessed" :
            
            definedCells.removeAll(keepCapacity: false)
            
            defineData()
            
            self.tableView.reloadData()
            state.removeLast()

            break
            
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
    
    final func unconfirmedTransactionsSuccessed(notification: NSNotification)
    {
        var incomingArray :[TransactionPostMetaData] = notification.object as! [TransactionPostMetaData]
        
        unconfirmedTransactions.removeAll(keepCapacity: false)
        
        for item in incomingArray
        {
            switch (item.type)
            {
            case transferTransaction :
                unconfirmedTransactions.append(item as! TransferTransaction)
            
            case multisigTransaction:
                
                var multisigT  = item as! MultisigTransaction
                
                switch(multisigT.innerTransaction.type)
                {
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
        
        var address :String = State.currentContact!.address
        
        for var index = 0  ; index < unconfirmedTransactions.count ; index++
        {
            if unconfirmedTransactions[index].recipient != address
            {
                unconfirmedTransactions.removeAtIndex(index)
                index--
            }
        }
        
        state.append("unconfirmedTransactionsSuccessed")
    }
    
    final func unconfirmedTransactionsDenied(notification: NSNotification)
    {
        state.append("unconfirmedTransactionsAllDenied")
    }

    
    override func viewDidAppear(animated: Bool)
    {

    }
    
    @IBAction func createTransaction(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToSendTransaction )
    }
    
    func  numberOfSectionsInTableView(UITableView) -> Int
    {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if definedCells.count > 0
        {
            switch (section)
            {
            case 0:
                return transactions.count + 1
                
            case 1:
                return unconfirmedTransactions.count
                
            default:
                break
            }
        }
        
        return 0
    }
    
    func setString(message :String)->CGFloat
    {
        var numberOfRows :Int = 0
        for component :String in message.componentsSeparatedByString("\n")
        {
            numberOfRows += 1
            numberOfRows += count(component) / rowLength
        }
        
        var height : Int = numberOfRows  * 17
        
        return CGFloat(height)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func tableView(tableView: UITableView,titleForHeaderInSection section: Int) -> String
    {
        switch section
        {
        case 1:
            return "unconfirmed transactions"
            
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if( !(indexPath.row == 0 && indexPath.section == 0) )
        {
            var index :Int = 0
            var cell : CustomMessageCell!

            switch (indexPath.section)
            {
            case 0:
                index = indexPath.row - 1
                cell = self.tableView.dequeueReusableCellWithIdentifier(definedCells[index].type) as! CustomMessageCell
                
                var transaction = transactions[index]
                var message :NSMutableAttributedString = NSMutableAttributedString(string: transactions[index].message_payload , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeCommon)!])
                
                if(transactions[index].amount as! Int != 0)
                {
                    var text :String = "\(Int(Double(transactions[index].amount) / 1000000) ) XEM"
                    if transactions[index].message_payload != ""
                    {
                        text = "\n" + text
                    }
                    
                    var messageXEMS :NSMutableAttributedString = NSMutableAttributedString(string:text , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: textSizeXEM)! ])
                    message.appendAttributedString(messageXEMS)
                }
                
                var messageDate :NSMutableAttributedString = NSMutableAttributedString(string:"\n" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: textSizeCommon)! ])
                message.appendAttributedString(messageDate)
                
                cell.message.attributedText = message
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm dd.MM.yy "
                
                var timeStamp = Double(transactions[index].timeStamp)
                var block = dataManager.getBlock(Double((transactions[index] as Transaction).height))
                
                if block != nil
                {
                    timeStamp += Double(block!.timeStamp) / 1000
                }
                
                cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: genesis_block_time + timeStamp))
                
                if(indexPath.row == tableView.numberOfRowsInSection(0) - 1)
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
                }
                
                cell.message.layer.cornerRadius = 5
                cell.message.layer.masksToBounds = true
                
                return cell
                
            case 1:
                index = indexPath.row
                cell = self.tableView.dequeueReusableCellWithIdentifier(definedCells[index + transactions.count].type) as! CustomMessageCell
                
                var transaction :TransferTransaction = unconfirmedTransactions[index]
                var message :NSMutableAttributedString = NSMutableAttributedString(string: transaction.message.payload , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeCommon)!])
                
                if(transaction.amount  != 0)
                {
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

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch (indexPath.section)
        {
        case 0:
            if indexPath.row == 0
            {
                var height :CGFloat = 0
                
                for cell in definedCells
                {
                    height += cell.height
                }
                
                if height >= self.tableView.bounds.height
                {
                    return 1
                }
                else
                {
                    return self.tableView.bounds.height - height
                }
            }
            else
            {
                return definedCells[indexPath.row - 1].height
            }
            
        case 1:
            if transactions.count  > 0
            {
                return definedCells[indexPath.row + transactions.count - 1].height
            }
            else
            {
                return definedCells[indexPath.row ].height
            }
            
        default:
            break
        }
        
        return 1
    }
    
    func sortMessages()
    {
        var accum :Transaction!
        for(var index = 0; index < transactions.count; index++)
        {
            var sorted = true
            
            for(var index = 0; index < transactions.count - 1; index++)
            {
                var height :Double!
                
                var valueA :Double = Double((transactions[index] as Transaction).id)
                
                var valueB :Double = Double((transactions[index + 1] as Transaction).id)
                
                if valueA > valueB
                {
                    sorted = false
                    accum = transactions[index]
                    transactions[index] = transactions[index + 1]
                    transactions[index + 1] = accum
                }
            }
            
            if sorted
            {
                break
            }
        }
    }
    
    final func defineData()
    {
        var publicKey :String = KeyGenerator().generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey))
        for transaction in transactions
        {
            var definedCell : DefinedCell = DefinedCell()
            if (transaction.signer != publicKey)
            {
                definedCell.type = "inCell"
            }
            else
            {
                definedCell.type = "outCell"
            }
            
            var height :CGFloat = heightForView(transaction.message_payload, font: UIFont(name: "HelveticaNeue", size: textSizeCommon)!, width: tableView.frame.width - 66)
            
            if  transaction.amount as! Int != 0
            {
                height += heightForView("\n \(Int(Double(transaction.amount) / 1000000) )" , font: UIFont(name: "HelveticaNeue", size: textSizeXEM)!, width: tableView.frame.width - 66)
            }
            else
            {
                height += 20 //date offset
            }
            
            definedCell.height =  height
            
            definedCells.append(definedCell)
        }
        
        for transaction in unconfirmedTransactions
        {
            var definedCell : DefinedCell = DefinedCell()
            definedCell.type = "unconfirmedCell"
            
            var height :CGFloat = heightForView(transaction.message.payload, font: UIFont(name: "HelveticaNeue", size: textSizeCommon)!, width: tableView.frame.width - 66)
            
            if  transaction.amount != 0
            {
                height += heightForView("\n \(Int(Double(transaction.amount) / 1000000) )" , font: UIFont(name: "HelveticaNeue", size: textSizeXEM)!, width: tableView.frame.width - 66)
            }
            
            definedCell.height =  height
            
            definedCells.append(definedCell)
        }
        self.tableView.reloadData()
    }
    
    func scrollToEnd(notification: NSNotification)
    {
        var indexPath1 :NSIndexPath!
        
        if(tableView.numberOfRowsInSection(1) == 0)
        {
            if (tableView.numberOfRowsInSection(0) != 0)
            {
                indexPath1 = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1 , inSection: 0)
            }
        }
        else
        {
            indexPath1 = NSIndexPath(forRow: tableView.numberOfRowsInSection(1) - 1 , inSection: 1)
        }
        
        if indexPath1 != nil
        {
            tableView.scrollToRowAtIndexPath(indexPath1, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }

    override func viewWillDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
