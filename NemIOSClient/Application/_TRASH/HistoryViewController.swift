import UIKit

class HistoryViewController: UIViewController , UITableViewDelegate, APIManagerDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chouseButton: AccountChooserButton!
    
    fileprivate var _modifications :[AggregateModificationTransaction] = []
    fileprivate var _mainAccount :AccountGetMetaData? = nil
    fileprivate var _activeAccount :AccountGetMetaData? = nil
    fileprivate var _currentCosignatories :[String] = []
    fileprivate var _contentViews :[UIViewController] = []

    fileprivate let _apiManager :APIManager =  APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _apiManager.delegate = self
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
//        State.currentVC = SegueToHistoryVC

    }
    
//    @IBAction func chouseAccount(sender: AnyObject) {
//        if _contentViews.count == 0 {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            
//            let accounts :AccountChooserViewController =  storyboard.instantiateViewControllerWithIdentifier("AccountChooserViewController") as! AccountChooserViewController
//            
//            accounts.view.frame = tableView.frame
//            
//            accounts.view.layer.opacity = 0
////            accounts.delegate = self
//            
//            var wallets = _mainAccount?.cosignatoryOf ?? []
//            
//            if _mainAccount != nil
//            {
//                wallets.append(self._mainAccount!)
//            }
//            accounts.wallets = wallets
//            
//            if accounts.wallets.count > 0
//            {
//                _contentViews.append(accounts)
//                self.view.addSubview(accounts.view)
//                
//                UIView.animateWithDuration(0.5, animations: { () -> Void in
//                    accounts.view.layer.opacity = 1
//                    }, completion: nil)
//            }
//        } else {
//            _contentViews.first?.view.removeFromSuperview()
//            _contentViews.removeFirst()
//        }
//    }
    
//    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
//        if self.delegate != nil && self.delegate!.respondsToSelector(#selector(MainVCDelegate.pageSelected(_:))) {
//            (self.delegate as! MainVCDelegate).pageSelected(SegueToMainMenu)
//        }
//    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return _modifications.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _modifications[section].modifications.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let  cell = tableView.dequeueReusableCell(withIdentifier: "title") as! KeyCell
            
            let maskPath :UIBezierPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer :CAShapeLayer = CAShapeLayer()
            maskLayer.frame = cell.bounds
            maskLayer.path = maskPath.cgPath
            cell.layer.mask = maskLayer
            cell.layer.masksToBounds = true

            cell.key.text = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var timeStamp = Double(_modifications[(indexPath as NSIndexPath).section].timeStamp )
            
            timeStamp += genesis_block_time
            
            cell.key.text = dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
            
            return cell
        }
        else {
            let modification :AccountModification = _modifications[(indexPath as NSIndexPath).section].modifications[(indexPath as NSIndexPath).row - 1]
            var cell :KeyCell? = nil
            if modification.modificationType == 1 {
                cell = self.tableView.dequeueReusableCell(withIdentifier: "add") as? KeyCell
                
                cell!.key.text = ""
                cell!.cellIndex = (indexPath as NSIndexPath).row
                
                cell!.key.text = modification.publicKey
            }
            else {
                cell = self.tableView.dequeueReusableCell(withIdentifier: "delete") as? KeyCell
                
                cell!.key.text = ""
                cell!.cellIndex = (indexPath as NSIndexPath).row
                
                cell!.key.text = modification.publicKey
            }
            
            if (indexPath as NSIndexPath).row == _modifications[(indexPath as NSIndexPath).section].modifications.count && cell != nil {
                let maskPath :UIBezierPath = UIBezierPath(roundedRect: cell!.bounds, byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], cornerRadii: CGSize(width: 10, height: 10))
                let maskLayer :CAShapeLayer = CAShapeLayer()
                maskLayer.frame = cell!.bounds
                maskLayer.path = maskPath.cgPath
                cell!.layer.mask = maskLayer
                cell!.layer.masksToBounds = true
            }
            
            return cell!
        }
    }
    
    //MARK: - AccountChousePopUp Methods
    
    func didChouseAccount(_ account: AccountGetMetaData) {
        
        if _contentViews.count > 0 {
            _contentViews.first?.view.removeFromSuperview()
            _contentViews.removeFirst()
        }
        
        _activeAccount = account
        _apiManager.accountTransfersAll(State.currentServer!, account_address: account.address)
        chouseButton.setTitle(account.address, for: UIControlState())
    }
    
    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(_ account: AccountGetMetaData?) {
        
        if account != nil {
            
            chouseButton.setTitle(account?.address, for: UIControlState())
            
            if _mainAccount == nil {
                _mainAccount = account
            }
            
            _activeAccount = account
            _apiManager.accountTransfersAll(State.currentServer!, account_address: account!.address)
        }
    }
    
    func accountTransfersAllResponceWithTransactions(_ data: [TransactionPostMetaData]?) {
        
        _modifications.removeAll()
        
        for inData in data ?? [] {
            switch (inData.type) {
            case multisigTransaction:
                
                let multisigT  = inData as! _MultisigTransaction
                
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
        
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }
    }
}
