import UIKit

class HistoryViewController: AbstractViewController , UITableViewDelegate
{
    var walletData :AccountGetMetaData!
    var timer :NSTimer!
    var state :[String] = ["none"]
    var currentCosignatories :[String] = [String]()

    @IBOutlet weak var chooseAccount: ButtonDropDown!
    @IBOutlet weak var tableView: UITableView!
    
    var modifications :[AggregateModificationTransaction] = [AggregateModificationTransaction]()
    var dataManager :CoreDataManager = CoreDataManager()
    var apiManager :APIManager =  APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if State.fromVC != SegueToHistoryVC {
            State.fromVC = SegueToHistoryVC
        }
        
        State.currentVC = SegueToHistoryVC
        
        var observer: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        observer.addObserver(self, selector: "accountGetDenied:", name: "accountGetDenied", object: nil)
        observer.addObserver(self, selector: "accountGetSuccessed:", name: "accountGetSuccessed", object: nil)
        observer.addObserver(self, selector: "accountTransfersAllSuccessed:", name: "accountTransfersAllSuccessed", object: nil)
        
        observer.postNotificationName("Title", object:"History" )

        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        
        if State.currentServer != nil {
            APIManager().accountGet(State.currentServer!, account_address: account_address)
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)

    }
    
    final func manageState() {
        switch (state.last!) {
        case "accountGetSuccessed" :
            var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
            var publicKey = KeyGenerator.generatePublicKey(privateKey)
            
            if publicKey == walletData.publicKey {
                var content :[String] = [String]()
                var contentActions :[funcBlock] = [funcBlock]()
                if walletData.cosignatoryOf.count > 0 {
                    for account in walletData.cosignatoryOf
                    {
                        content.append(account.address)
                        contentActions.append(
                            {
                                () -> () in
                                
                                if State.currentServer != nil
                                {
                                    self.apiManager.accountGet(State.currentServer!, account_address: account.address)
                                }
                        })
                    }
                    chooseAccount.setContent(content, contentActions: contentActions)

                }
                else {
                    APIManager().accountTransfersAll(State.currentServer!, account_address: walletData.address)
                    chooseAccount.setTitle("This account" as String, forState: UIControlState.Normal)
                    chooseAccount.setTitle("This account" as String, forState: UIControlState.Selected)
                    chooseAccount.setTitle("This account" as String, forState: UIControlState.Disabled)
                }
            }
            else {
                if State.currentServer != nil {
                    APIManager().accountTransfersAll(State.currentServer!, account_address: walletData.address)
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToServerTable )
                }

            }
            state.removeLast()

        case "accountTransfersAllSuccessed" :

            
            self.tableView.reloadData()
            state.removeLast()

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

    final func accountTransfersAllSuccessed(notification: NSNotification) {
        var data :[TransactionPostMetaData] = notification.object as! [TransactionPostMetaData]
        
        modifications.removeAll(keepCapacity: false)
        
        for inData in data {
            switch (inData.type) {
            case multisigTransaction:
                
                var multisigT  = inData as! MultisigTransaction
                
                switch(multisigT.innerTransaction.type) {
                case multisigAggregateModificationTransaction :
                    
                    var modTransaction :AggregateModificationTransaction = multisigT.innerTransaction as! AggregateModificationTransaction
                    modifications.append(modTransaction)
                    
                default:
                    break
                }
                
            case multisigAggregateModificationTransaction:
                
                var modTransaction :AggregateModificationTransaction = inData as! AggregateModificationTransaction
                modifications.append(modTransaction)
                
            default:
                break
            }
        }
        
        state.append("accountTransfersAllSuccessed")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return modifications.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modifications[section].modifications.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var  cell = tableView.dequeueReusableCellWithIdentifier("title") as! KeyCell
            
            let maskPath :UIBezierPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii: CGSizeMake(10, 10))
            let maskLayer :CAShapeLayer = CAShapeLayer()
            maskLayer.frame = cell.bounds
            maskLayer.path = maskPath.CGPath
            cell.layer.mask = maskLayer
            cell.layer.masksToBounds = true

            cell.key.text = ""
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var timeStamp = Double(modifications[indexPath.section].timeStamp )
            
            timeStamp += genesis_block_time
            
            cell.key.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
            
            return cell
        }
        else {
            var modification :AccountModification = modifications[indexPath.section].modifications[indexPath.row - 1]
            var cell :KeyCell? = nil
            if modification.modificationType == 1 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("add") as? KeyCell
                
                cell!.key.text = ""
                cell!.cellIndex = indexPath.row
                
                cell!.key.text = modification.publicKey
            }
            else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("delete") as? KeyCell
                
                cell!.key.text = ""
                cell!.cellIndex = indexPath.row
                
                cell!.key.text = modification.publicKey
            }
            
            if indexPath.row == modifications[indexPath.section].modifications.count && cell != nil {
                var maskPath :UIBezierPath = UIBezierPath(roundedRect: cell!.bounds, byRoundingCorners: UIRectCorner.BottomLeft | UIRectCorner.BottomRight, cornerRadii: CGSizeMake(10, 10))
                var maskLayer :CAShapeLayer = CAShapeLayer()
                maskLayer.frame = cell!.bounds
                maskLayer.path = maskPath.CGPath
                cell!.layer.mask = maskLayer
                cell!.layer.masksToBounds = true
            }
            
            return cell!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
