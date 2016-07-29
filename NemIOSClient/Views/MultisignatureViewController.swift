//
//  MultisignatureViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class MultisignatureViewController: UIViewController, UITableViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, AddCosigPopUptDelegate, AccountsChousePopUpDelegate
{

    @IBOutlet weak var chouseButton: AccountChooserButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var minCosigField: NEMTextField!
    @IBOutlet weak var accountLabel: UILabel!
    
    private var _mainAccount :AccountGetMetaData? = nil
    private var _activeAccount :AccountGetMetaData? = nil
    
    private let _apiManager :APIManager =  APIManager()
    private var _popUp :UIViewController? = nil

    private var _currentCosignatories :[String] = []
    private var _addArray :[String] = []
    private var _removeArray :[String] = []
    
    private var _isMultisig :Bool = false
    
    var minCosigValue = 0
    var maxCosigValue = 0
    
    var minCosig :Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _apiManager.delegate = self
        title = "MULTISIG".localized()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueTomultisigAccountManager
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = _currentCosignatories.count + _addArray.count
        
        if !_isMultisig {
            count += 1
            
            if _activeAccount != nil && (_activeAccount!.cosignatories.count > 0 || _addArray.count > 0){
                count += 1
            }
        }
        
        if _addArray.count > 0 || _removeArray.count > 0 || minCosig != nil {
            count += 1
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row < _currentCosignatories.count + _addArray.count {
            let cell :MultisignatureSignerTableViewCell = tableView.dequeueReusableCellWithIdentifier("cosig cell")! as! MultisignatureSignerTableViewCell
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
                let cell :MultisignatureMinimumSignerAmountTableViewCell = tableView.dequeueReusableCellWithIdentifier("min cosig cell") as! MultisignatureMinimumSignerAmountTableViewCell
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
            } else if _removeArray.count > 0 && (_activeAccount!.minCosignatories ?? 0) != 0 {
                relativeChange = min( _activeAccount!.minCosignatories!, _activeAccount!.cosignatories.count - _removeArray.count) - _activeAccount!.minCosignatories!
            }
            
            if relativeChange != 0{
                fee += 6
            }
            
            let transaction :AggregateModificationTransaction = AggregateModificationTransaction()
            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
            let publickey = self._activeAccount!.publicKey ?? KeyGenerator.generatePublicKey(privateKey!)
            
            transaction.timeStamp = TimeSynchronizator.nemTime
            transaction.deadline = TimeSynchronizator.nemTime + waitTime
            transaction.version = 2
            transaction.signer = publickey
            transaction.privateKey = privateKey
            transaction.minCosignatory = relativeChange
            
            for publickey in _sortModifications(self._addArray) {
                transaction.addModification(1, publicKey: publickey)
            }
            
            for publickey in _sortModifications(self._removeArray)
            {
                transaction.addModification(2, publicKey: publickey)
            }
            
            transaction.fee = Double(fee)
            
            self._apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
        }
    }
    
    
    //MARK: - @IBAction
    
    @IBAction func minCosigChaned(sender: UITextField) {
        var isNormal = false
        print()
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
            if let minCosignatories = _activeAccount!.minCosignatories {
                let currentValue = (minCosignatories == 0 || minCosignatories == _activeAccount!.cosignatories.count) ? _activeAccount!.cosignatories.count - _removeArray.count : minCosignatories
                
                sender.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER".localized()), "\(currentValue)")
            }
        } else {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func chouseAccount(sender: AnyObject) {
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
            return
        }
        
        if (_mainAccount?.cosignatoryOf ?? []).isEmpty {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let accounts :AccountChooserViewController =  storyboard.instantiateViewControllerWithIdentifier("AccountChooserViewController") as! AccountChooserViewController
        
        accounts.view.frame = tableView.frame
        
        accounts.view.layer.opacity = 0
//        accounts.delegate = self
        
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
        
        let popUp :MultisignatureAddSignerViewController =  storyboard.instantiateViewControllerWithIdentifier("MultisignatureAddSignerViewController") as! MultisignatureAddSignerViewController
        popUp.view.frame = CGRect(x: 0, y: 40, width: popUp.view.frame.width, height: popUp.view.frame.height - 40)
        popUp.view.layer.opacity = 0
//        popUp.delegate = self
        
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
    
    private func _sortModifications(modifications :[String]) -> [String] {
        var resutModifications = modifications
        for var sorted = false ; !sorted; {
            sorted = true
            for var i = 1; i < resutModifications.count ; i += 1 {
                let previousAddress = AddressGenerator.generateAddress(resutModifications[i-1])
                let currentAddress = AddressGenerator.generateAddress(resutModifications[i])
                
                if previousAddress.compare(currentAddress) == NSComparisonResult.OrderedDescending {
                    let mod = resutModifications[i]
                    resutModifications[i] = resutModifications[i-1]
                    resutModifications[i-1] = mod
                    sorted = false
                }
            }
        }
        return resutModifications
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
        chouseButton.setTitle(account!.address.nemName(), forState: UIControlState.Normal)
        accountLabel.text = account!.address.nemName()

        if account != nil {
            if _mainAccount == nil {
                if account!.cosignatoryOf.count > 0 {
                    chouseButton.hidden = false
                    accountLabel.hidden = true
                } else {
                    chouseButton.hidden = true
                    accountLabel.hidden = false
                }
                
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
        
        self.tableView.reloadData()
        
        if !(data ?? []).isEmpty {
            message = "TRANSACTION_ANOUNCE_SUCCESS".localized()
            _showPopUp(message)
        }
    }
    
    func failWithError(message: String) {
        _showPopUp(message.localized())
    }
}