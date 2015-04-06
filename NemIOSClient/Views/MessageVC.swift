import UIKit

class MessageVC: UIViewController , UITableViewDelegate , UIAlertViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var NEMinput: UITextField!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var fee: UILabel!
    
    var transactionFee :Double = 10;
    let dataManager :CoreDataManager = CoreDataManager()
    let contact :Correspondent = State.currentContact!
    var transactions  :[Transaction]!
    var showKeyboard :Bool = false
    var nems :Int = 0
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

        transactions = contact.transactions.allObjects as [Transaction]
        
        sortMessages()
        
        var format = ".0"
        
        balance.text = "Balance :\((Double(State.currentWallet!.balance) / 1000000).format(format)) XEMs"


        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: "scrollToEnd:", name: "scrollToEnd", object: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:State.currentContact!.name )
        
        inputText.layer.cornerRadius = 2
        NEMinput.layer.cornerRadius = 2
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    @IBAction func typing(sender: NEMTextField)
    {
        countTransactionFee()
    }
    
    final func countTransactionFee()
    {
        if nems > 8
        {
            transactionFee = max(2, 99 * atan(Double(nems) / 0.15))
        }
        else
        {
            transactionFee = 10
        }
        
        if inputText.text.utf16Count != 0
        {
            transactionFee += Double(2 * max(1, Int(inputText.text.utf16Count / 16)))
        }
        
        self.fee.text = "Fee : \(Int64(transactionFee))"
    }
    
    override func viewDidAppear(animated: Bool)
    {

    }
    
    @IBAction func closeKeyboard(sender: UITextField)
    {
        sender.becomeFirstResponder()
    }
    
    @IBAction func doNotScroll(sender: UITextField)
    {
        showKeyboard = true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(transactions.count < 12)
        {
            return 12
        }
        else
        {
            return transactions.count
        }
    }
    
    @IBAction func send(sender: AnyObject)
    {
        if inputText.text != "" || nems != 0
        {
            var transaction :TransactionPostMetaData = TransactionPostMetaData()
            var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
            var publickey = KeyGenerator().generatePublicKey(privateKey)
            var address = contact.address
            
            transaction.timeStamp = TimeSynchronizator.nemTime
            transaction.amount = Double(nems)
            transaction.message.payload = inputText.text
            transaction.fee = transactionFee
            transaction.recipient = address
            transaction.type = 257
            transaction.deadline =  TimeSynchronizator.nemTime + waitTime
            transaction.message.type = 1
            transaction.version = 1
            transaction.signer = publickey
            transaction.privateKey = privateKey

            APIManager().prepareAnnounce(State.currentServer!, transaction: transaction)
            
            nems = 0;
            inputText.text = ""
            NEMinput.text = ""
            
            transactions = contact.transactions.allObjects as [Transaction]
            sortMessages()
                
            tableView.reloadData()
                
            NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
        }
    }
    
    func setString(message :String)->CGFloat
    {
        var numberOfRows :Int = 0
        for component :String in message.componentsSeparatedByString("\n")
        {
            numberOfRows += 1
            numberOfRows += countElements(component) / rowLength
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(12 - indexPath.row  <= transactions.count)
        {
            var index :Int!
            
            if(transactions.count < 12)
            {
                index = indexPath.row  -  12 + transactions.count
            }
            else
            {
                index = indexPath.row 
            }
            
            var cell : CustomMessageCell!
            
            if (transactions[index].signer != KeyGenerator().generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey)))
            {
                cell = self.tableView.dequeueReusableCellWithIdentifier("inCell") as CustomMessageCell
            }
            else
            {
                cell = self.tableView.dequeueReusableCellWithIdentifier("outCell") as CustomMessageCell
            }
            
            var message :NSMutableAttributedString = NSMutableAttributedString(string: transactions[index].message_payload , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeCommon)!])
            
            if(transactions[index].amount as Int != 0)
            {
                var text :String = "\(Int(Double(transactions[index].amount) / 1000000) ) XEMs"
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
            
            var timeStamp = Double(transactions[index].timeStamp) / 1000
            var block = dataManager.getBlock(Double((transactions[index] as Transaction).height))
            
            timeStamp += Double(block.timeStamp) / 1000
            
            cell.date.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: genesis_block_time + timeStamp))
            
            if(indexPath.row == tableView.numberOfRowsInSection(0) - 1)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
            }
            
            cell.message.layer.cornerRadius = 5
            cell.message.layer.masksToBounds = true
            
            return cell
        }
        else
        {
            var cell    :UITableViewCell  = self.tableView.dequeueReusableCellWithIdentifier("simpl") as UITableViewCell
            return cell as UITableViewCell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if(12 - indexPath.row  <= transactions.count)
        {
            var index :Int!
            if(transactions.count < 12)
            {
                index = indexPath.row  -  12 + transactions.count
            }
            else
            {
                index = indexPath.row
            }
            
            var height :CGFloat = heightForView(transactions[index].message_payload, font: UIFont(name: "HelveticaNeue", size: textSizeCommon)!, width: tableView.frame.width - 66)
        
            if  transactions[index].amount as Int != 0
            {
                height += heightForView("\n \(Int(Double(transactions[index].amount) / 1000000) )" , font: UIFont(name: "HelveticaNeue", size: textSizeXEM)!, width: tableView.frame.width - 66)
            }
            else
            {
                height += 20 //date offset
            }
            
            return  height
        }
        else
        {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {

    }
    
    @IBAction func addNems(sender: AnyObject)
    {
        if (sender as UITextField).text.toInt() != nil
        {
            self.nems = (sender as UITextField).text.toInt()!
        }
        
        countTransactionFee()
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
                
                var valueA :Double = Double((transactions[index] as Transaction).timeStamp)
                height = Double((transactions[index] as Transaction).height)
                valueA  += Double(dataManager.getBlock(height).timeStamp)
                
                var valueB :Double = Double((transactions[index + 1] as Transaction).timeStamp)
                height = Double((transactions[index + 1] as Transaction).height)
                valueB  += Double(dataManager.getBlock(height).timeStamp)
                
                
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
    
    func scrollToEnd(notification: NSNotification)
    {
        var pos :Int!
        if(tableView.numberOfRowsInSection(0) < 12)
        {
            pos = 0
        }
        else
        {
            pos = tableView.numberOfRowsInSection(0) - 1
        }
        var indexPath1 :NSIndexPath = NSIndexPath(forRow: pos , inSection: 0)
        
        tableView.scrollToRowAtIndexPath(indexPath1, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.25
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.view.frame = CGRectMake(0, -keyboardHeight, self.view.bounds.width, self.view.bounds.height)
                    }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
            var keyboardHeight:CGFloat = keyboardSize.height
            

        
            var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, (self.view.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            
                }, completion: nil)
        }
    }

    override func viewWillDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}
