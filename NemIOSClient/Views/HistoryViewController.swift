import UIKit

class HistoryViewController: AbstractViewController , UITableViewDelegate, APIManagerDelegate, AccountsChousePopUpDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chouseButton: ChouseButton!
    
    private var _modifications :[AggregateModificationTransaction] = []
    private var _mainAccount :AccountGetMetaData? = nil
    private var _activeAccount :AccountGetMetaData? = nil
    private var _currentCosignatories :[String] = []
    private var _contentViews :[AbstractViewController] = []

    private let _apiManager :APIManager =  APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.currentVC = SegueToHistoryVC
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    @IBAction func chouseAccount(sender: AnyObject) {
        if _contentViews.count == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let accounts :AccountsChousePopUp =  storyboard.instantiateViewControllerWithIdentifier("AccountsChousePopUp") as! AccountsChousePopUp
            
            accounts.view.frame = tableView.frame
            
            accounts.view.layer.opacity = 0
            accounts.delegate = self
            
            var wallets = _mainAccount?.cosignatoryOf ?? []
            
            if _mainAccount != nil
            {
                wallets.append(self._mainAccount!)
            }
            accounts.wallets = wallets
            
            if accounts.wallets.count > 0
            {
                _contentViews.append(accounts)
                self.view.addSubview(accounts.view)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    accounts.view.layer.opacity = 1
                    }, completion: nil)
            }
        } else {
            _contentViews.first?.view.removeFromSuperview()
            _contentViews.removeFirst()
        }
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMainMenu)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _modifications.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _modifications[section].modifications.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let  cell = tableView.dequeueReusableCellWithIdentifier("title") as! KeyCell
            
            let maskPath :UIBezierPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.TopRight], cornerRadii: CGSizeMake(10, 10))
            let maskLayer :CAShapeLayer = CAShapeLayer()
            maskLayer.frame = cell.bounds
            maskLayer.path = maskPath.CGPath
            cell.layer.mask = maskLayer
            cell.layer.masksToBounds = true

            cell.key.text = ""
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var timeStamp = Double(_modifications[indexPath.section].timeStamp )
            
            timeStamp += genesis_block_time
            
            cell.key.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
            
            return cell
        }
        else {
            let modification :AccountModification = _modifications[indexPath.section].modifications[indexPath.row - 1]
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
            
            if indexPath.row == _modifications[indexPath.section].modifications.count && cell != nil {
                let maskPath :UIBezierPath = UIBezierPath(roundedRect: cell!.bounds, byRoundingCorners: [UIRectCorner.BottomLeft, UIRectCorner.BottomRight], cornerRadii: CGSizeMake(10, 10))
                let maskLayer :CAShapeLayer = CAShapeLayer()
                maskLayer.frame = cell!.bounds
                maskLayer.path = maskPath.CGPath
                cell!.layer.mask = maskLayer
                cell!.layer.masksToBounds = true
            }
            
            return cell!
        }
    }
    
    //MARK: - AccountChousePopUp Methods
    
    func didChouseAccount(account: AccountGetMetaData) {
        
        if _contentViews.count > 0 {
            _contentViews.first?.view.removeFromSuperview()
            _contentViews.removeFirst()
        }
        
        _activeAccount = account
        _apiManager.accountTransfersAll(State.currentServer!, account_address: account.address)
        chouseButton.setTitle(account.address, forState: UIControlState.Normal)
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        
        if account != nil {
            
            chouseButton.setTitle(account?.address, forState: UIControlState.Normal)
            
            if _mainAccount == nil {
                _mainAccount = account
            }
            
            _activeAccount = account
            _apiManager.accountTransfersAll(State.currentServer!, account_address: account!.address)
        }
    }
    
    func accountTransfersAllResponceWithTransactions(data: [TransactionPostMetaData]?) {
        
        _modifications.removeAll()
        
        for inData in data ?? [] {
            switch (inData.type) {
            case multisigTransaction:
                
                let multisigT  = inData as! MultisigTransaction
                
                switch(multisigT.innerTransaction.type) {
                case multisigAggregateModificationTransaction :
                    
                    let modTransaction :AggregateModificationTransaction = multisigT.innerTransaction as! AggregateModificationTransaction
                    _modifications.append(modTransaction)
                    
                default:
                    break
                }
                
            case multisigAggregateModificationTransaction:
                
                let modTransaction :AggregateModificationTransaction = inData as! AggregateModificationTransaction
                _modifications.append(modTransaction)
                
            default:
                break
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
}
