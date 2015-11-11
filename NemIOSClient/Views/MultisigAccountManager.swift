import UIKit

class MultisigAccountManager: AbstractViewController, UITableViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, AddCosigPopUptDelegate, AccountsChousePopUpDelegate
{

    @IBOutlet weak var chouseButton: ChouseButton!
    @IBOutlet weak var tableView: UITableView!
    
    var currentCosignatories :[String] = [String]()
    var removeArray :[AccountGetMetaData]!
    var addArray = [String]()
    
    private var _mainAccount :AccountGetMetaData? = nil
    private var _activeAccount :AccountGetMetaData? = nil
    
    private let _apiManager :APIManager =  APIManager()
    
    private var _popUps :[AbstractViewController] = []
    
    private var _currentCosignatories :[String] = []
    private var _addArray :[String] = []
    private var _removeArray :[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        State.fromVC = SegueTomultisigAccountManager
        State.currentVC = SegueTomultisigAccountManager
        
        _apiManager.delegate = self
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = currentCosignatories.count + _addArray.count + 1
        if _addArray.count > 0 || _removeArray.count > 0 {
            count++
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == tableView.numberOfRowsInSection(0) - 1 {
            if (_addArray.count + _removeArray.count) > 0 {
                let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier("save cell")!
                return cell
            } else {
                let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier("add cosig cell")!
                return cell
            }
        } else {
            if indexPath.row == _currentCosignatories.count + _addArray.count {
                let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier("add cosig cell")!
                return cell
            } else {
                let cell :CosigTableViewCell = tableView.dequeueReusableCellWithIdentifier("cosig cell")! as! CosigTableViewCell
                cell.infoLabel.numberOfLines = 2
                
                var index = 0
                
                if indexPath.row >= _currentCosignatories.count {
                    index = indexPath.row - _currentCosignatories.count
                    
                    if index < _addArray.count {
                        cell.isEditable = true
                        cell.infoLabel.text = _addArray[index]
                    }
                    
                } else {
                    cell.isEditable = !(_removeArray.count > 0)
                    cell.infoLabel.text = _currentCosignatories[indexPath.row]
                }
                
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.numberOfRowsInSection(0) - 1 {
            if (_addArray.count + _removeArray.count) == 0 {
                _addCosig()
            }
        } else {
            if indexPath.row == tableView.numberOfRowsInSection(0) - 2 {
                if (_addArray.count + _removeArray.count) > 0 {
                   _addCosig()
                }
            }
        }
    }
    
    func deleteCell(cell: EditableTableViewCell) {
        var index = tableView.indexPathForCell(cell)!.row
        
        if index >= _currentCosignatories.count {
            index = index - _currentCosignatories.count
            _addArray.removeAtIndex(index)
        } else {
            currentCosignatories.removeAtIndex(index)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func saveChanges(sender: AnyObject) {
        
        if _removeArray.count > 1 {
            _showPopUp( NSLocalizedString("MULTISIG_REMOVE_COUNT_ERROR", comment: "Description"))
        }
        else if (_currentCosignatories.count + _addArray.count) > 16 {
            _showPopUp( NSLocalizedString("MULTISIG_COSIGNATORIES_COUNT_ERROR", comment: "Description"))
        }
        else {
            let fee = 10 + 6 * Int64(_addArray.count + _removeArray.count)
            
            let alert1 :UIAlertController = UIAlertController(title: NSLocalizedString("INFO", comment: "Title"), message:
                String(format: NSLocalizedString("MULTISIG_CHANGES_CONFIRMATION", comment: "Description"), fee), preferredStyle: UIAlertControllerStyle.Alert)
            
            let confirm :UIAlertAction = UIAlertAction(title: NSLocalizedString("CONFIRM", comment: "Title"), style: UIAlertActionStyle.Default) {
                    alertAction -> Void in
                    
                    let transaction :AggregateModificationTransaction = AggregateModificationTransaction()
                    let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
                    let publickey = self._activeAccount!.publicKey!
                    
                    transaction.timeStamp = TimeSynchronizator.nemTime
                    transaction.deadline = TimeSynchronizator.nemTime + waitTime
                    transaction.version = 1
                    transaction.signer = publickey
                    transaction.privateKey = privateKey
                    transaction.minCosignatory = 0
                    
                    for publickey in self._removeArray
                    {
                        transaction.addModification(2, publicKey: publickey)
                    }
                    
                    for publickey in self._addArray
                    {
                        transaction.addModification(1, publicKey: publickey)
                    }
                    
                transaction.fee = Double(fee)
                    
                    self._apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
            }
            
            let cancel :UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Title"), style: UIAlertActionStyle.Cancel) {
                alertAction -> Void in
            }
            
            alert1.addAction(cancel)
            alert1.addAction(confirm)
            
            self.presentViewController(alert1, animated: true, completion: nil)
        }
    }
    
    //MARK: - @IBAction
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    @IBAction func chouseAccount(sender: AnyObject) {
        if _popUps.count == 0 {
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
                _popUps.append(accounts)
                self.view.addSubview(accounts.view)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    accounts.view.layer.opacity = 1
                    }, completion: nil)
            }
        } else {
            _popUps.first?.view.removeFromSuperview()
            _popUps.removeFirst()
        }
    }
    
    //MARK: - Private Methods
    
    private func _addCosig() {
        if _popUps.count == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let popUp :AddCosigPopUp =  storyboard.instantiateViewControllerWithIdentifier("AddCustomCosig") as! AddCosigPopUp
            popUp.view.frame = CGRect(x: 0, y: 40, width: popUp.view.frame.width, height: popUp.view.frame.height - 40)
            popUp.view.layer.opacity = 0
            popUp.delegate = self
            
            _popUps.append(popUp)
            self.view.addSubview(popUp.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                popUp.view.layer.opacity = 1
                }, completion: nil)
        } else {
            _popUps.first?.view.removeFromSuperview()
            _popUps.first?.removeFromParentViewController()
            _popUps.removeFirst()
        }
    }
    
    private func _generateTableData() {
        var newCosigList :[String] = []
        
        for cosig in _activeAccount!.cosignatories {
            newCosigList.append(cosig.publicKey ?? "not registered in NIS" )
        }
        
        _currentCosignatories = newCosigList
        _addArray = []
        _removeArray = []
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
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
    
    //MARK: - AccountChousePopUp Methods

    func addCosig(publicKey: String) {
        _addArray.append(publicKey)
        tableView.reloadData()
    }
    
    //MARK: - AccountChousePopUp Methods
    
    func didChouseAccount(account: AccountGetMetaData) {
        
        if _popUps.count > 0 {
            _popUps.first?.view.removeFromSuperview()
            _popUps.removeFirst()
        }
        _activeAccount = nil
        _apiManager.accountGet(State.currentServer!, account_address: account.address)
    }

    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        
        if account != nil {
            
            chouseButton.setTitle(account?.address, forState: UIControlState.Normal)
            
            if _mainAccount == nil {
                _mainAccount = account
            }
            
            if _activeAccount == nil {
                _activeAccount = account
                _generateTableData()
            }
        }
    }
    
    func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
        if data != nil && data!.count > 0 {
            func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
                
                var message :String = ""
                if (data ?? []).isEmpty {
                    message = NSLocalizedString("TRANSACTION_ANOUNCE_FAILED", comment: "Dsecription")
                } else {
                    message = NSLocalizedString("TRANSACTION_ANOUNCE_SUCCESS", comment: "Description")
                }
                
                _showPopUp(message)
            }
        }
    }
}