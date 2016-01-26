import UIKit

class MultisigAccountManager: AbstractViewController, UITableViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, AddCosigPopUptDelegate, AccountsChousePopUpDelegate
{

    @IBOutlet weak var chouseButton: ChouseButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var minCosigField: NEMTextField!
    
    private var _mainAccount :AccountGetMetaData? = nil
    private var _activeAccount :AccountGetMetaData? = nil
    
    private let _apiManager :APIManager =  APIManager()
    private var _popUp :AbstractViewController? = nil

    private var _currentCosignatories :[String] = []
    private var _addArray :[String] = []
    private var _removeArray :[String] = []
    
    private var _isMultisig :Bool = false
    
    var minCosigValue = 0
    var maxCosigValue = 0
    
    var minCosig :Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        State.currentVC = SegueTomultisigAccountManager
        
        _apiManager.delegate = self
        titleLabel.text = "MULTISIG".localized()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = _currentCosignatories.count + _addArray.count
        
        if !_isMultisig {
            count++
            
            if _activeAccount != nil && (_activeAccount!.cosignatories.count > 0 || _addArray.count > 0){
                count++
            }
        }
        
        if _addArray.count > 0 || _removeArray.count > 0 || minCosig != nil {
            count++
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row < _currentCosignatories.count + _addArray.count {
            let cell :CosigTableViewCell = tableView.dequeueReusableCellWithIdentifier("cosig cell")! as! CosigTableViewCell
            cell.infoLabel.numberOfLines = 2
            cell.editDelegate = self
            cell.isEditable = (_removeArray.count == 0 && (_removeArray.count + _addArray.count) < 16)  && !self._isMultisig
            
            var index = 0
            if indexPath.row >= _currentCosignatories.count {
                index = indexPath.row - _currentCosignatories.count
                
                if index < _addArray.count {
                    cell.infoLabel.text =  AddressGenerator.generateAddress(_addArray[index]).nemName()
                }
                
            } else {
                cell.infoLabel.text = AddressGenerator.generateAddress(_currentCosignatories[indexPath.row]).nemName()
            }
            
            return cell
        } else {
            let index = indexPath.row - _currentCosignatories.count - _addArray.count
            
            switch index {
            case 0:
                let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier("add cosig cell")!
                return cell
                
            case 1:
                let cell :TextFieldTableViewCell = tableView.dequeueReusableCellWithIdentifier("min cosig cell") as! TextFieldTableViewCell
                let currentValue = (_activeAccount!.minCosignatories == 0 || _activeAccount!.minCosignatories == _activeAccount!.cosignatories.count) ? _activeAccount!.cosignatories.count - _removeArray.count : _activeAccount!.minCosignatories ?? _addArray.count
                let max = _activeAccount!.cosignatories.count - _removeArray.count
                if self.minCosig != nil {
                    cell.textField.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER_CHANGED".localized()), "\(self.minCosig!)")
                } else {
                    cell.textField.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER".localized()), "\(currentValue)")
                }
                
                self.minCosigValue = (max == 0) ? 0 : 1
                self.maxCosigValue = max
                
                return cell
                
            case 2:
                let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier("save cell")!
                return cell
                
            default :
                let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier("add cosig cell")!
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row >= _addArray.count + _currentCosignatories.count {
            _addCosig()
        }
    }
    
    func deleteCell(cell: EditableTableViewCell) {
        var index = tableView.indexPathForCell(cell)!.row
        
        if index >= _currentCosignatories.count {
            index = index - _currentCosignatories.count
            _addArray.removeAtIndex(index)
        } else {
            _removeArray.append(_currentCosignatories[index])
            _currentCosignatories.removeAtIndex(index)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func saveChanges(sender: AnyObject) {
        
        if _removeArray.count > 1 {
            _showPopUp( "MULTISIG_REMOVE_COUNT_ERROR".localized())
        }
        else if (_currentCosignatories.count + _addArray.count) > 16 {
            _showPopUp( "MULTISIG_COSIGNATORIES_COUNT_ERROR".localized())
        }
        else {
            var fee = 10 + 6 * Int64(_addArray.count + _removeArray.count)
            
            var relativeChange = 0
            
            if self.minCosig != nil {
                relativeChange = minCosig! - _activeAccount!.minCosignatories!
                fee += 6
            }
            
            let transaction :AggregateModificationTransaction = AggregateModificationTransaction()
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
            let publickey = self._activeAccount!.publicKey!
            
            transaction.timeStamp = TimeSynchronizator.nemTime
            transaction.deadline = TimeSynchronizator.nemTime + waitTime
            transaction.version = 2
            transaction.signer = publickey
            transaction.privateKey = privateKey
            transaction.minCosignatory = relativeChange
            
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
    }
    
    //MARK: - @IBAction
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMainMenu)
        }
    }
    
    @IBAction func minCosigChaned(sender: UITextField) {
        var isNormal = false
        if let value = Int(sender.text!) {
            if value >= minCosigValue && value <= maxCosigValue {
                isNormal = true
                self.minCosig = value
                sender.text = ""
                let currentValue = (_activeAccount!.minCosignatories == 0 || _activeAccount!.minCosignatories == _activeAccount!.cosignatories.count) ? _activeAccount!.cosignatories.count - _removeArray.count : _activeAccount!.minCosignatories!

                if currentValue == value {
                    sender.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER".localized()), "\(value)")
                } else {
                    sender.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER_CHANGED".localized()), "\(value)")
                }
            }
        }
        
        if !isNormal {
            sender.text = ""
            self.minCosig = nil
            let currentValue = (_activeAccount!.minCosignatories == 0 || _activeAccount!.minCosignatories == _activeAccount!.cosignatories.count) ? _activeAccount!.cosignatories.count - _removeArray.count : _activeAccount!.minCosignatories!

            sender.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER".localized()), "\(currentValue)")
        } else {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func chouseAccount(sender: AnyObject) {
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
        
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
            _popUp = accounts
            self.view.addSubview(accounts.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                accounts.view.layer.opacity = 1
                }, completion: nil)
        }
    }
    
    //MARK: - Private Methods
    
    private func _addCosig() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popUp :AddCosigPopUp =  storyboard.instantiateViewControllerWithIdentifier("AddCustomCosig") as! AddCosigPopUp
        popUp.view.frame = CGRect(x: 0, y: 40, width: popUp.view.frame.width, height: popUp.view.frame.height - 40)
        popUp.view.layer.opacity = 0
        popUp.delegate = self
        
        _popUp = popUp
        self.view.addSubview(popUp.view)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            popUp.view.layer.opacity = 1
            }, completion: nil)
    }
    
    private func _generateTableData() {
        var newCosigList :[String] = []
        
        for cosig in _activeAccount!.cosignatories {
            newCosigList.append(cosig.publicKey ?? "NO_PUBLICKEY".localized() )
        }
        
        _currentCosignatories = newCosigList
        _addArray = []
        _removeArray = []
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    private final func _showPopUp(message :String){
        
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default) {
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
        
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
        _activeAccount = nil
        _apiManager.accountGet(State.currentServer!, account_address: account.address)
    }

    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(account: AccountGetMetaData?) {
        
        if account != nil {
            
            chouseButton.setTitle(account?.address.nemName(), forState: UIControlState.Normal)
            
            if _mainAccount == nil {
                if account?.cosignatories.count > 0 {
                    _isMultisig = true
                }
                
                _mainAccount = account
            }
            
            if _activeAccount == nil {
                _activeAccount = account
                _generateTableData()
            }
        }
    }
    
    func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
        
        var message :String = ""
        
        minCosig = nil
        _addArray = []
        _removeArray = []
        
        if (data ?? []).isEmpty {
            message = "TRANSACTION_ANOUNCE_FAILED".localized()
        } else {
            message = "TRANSACTION_ANOUNCE_SUCCESS".localized()
        }
        
        _showPopUp(message)
    }
}