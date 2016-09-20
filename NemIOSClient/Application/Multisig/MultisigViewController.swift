//
//  MultisigViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MultisigViewController: UIViewController, UITableViewDelegate, APIManagerDelegate, EditableTableViewCellDelegate, AddCosigPopUptDelegate
{

    @IBOutlet weak var chouseButton: AccountChooserButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var minCosigField: NEMTextField!
    @IBOutlet weak var accountLabel: UILabel!
    
    fileprivate var _mainAccount :AccountGetMetaData? = nil
    fileprivate var _activeAccount :AccountGetMetaData? = nil
    
    fileprivate let _apiManager :APIManager =  APIManager()
    fileprivate var _popUp :UIViewController? = nil

    fileprivate var _currentCosignatories :[String] = []
    fileprivate var _addArray :[String] = []
    fileprivate var _removeArray :[String] = []
    
    fileprivate var _isMultisig :Bool = false
    
    var minCosigValue = 0
    var maxCosigValue = 0
    
    var minCosig :Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _apiManager.delegate = self
        title = "MULTISIG".localized()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        let privateKey = HashManager.AES256Decrypt(inputText: State.currentWallet!.privateKey, key: State.loadData!.password!)
        let account_address = AddressGenerator.generateAddressFromPrivateKey(privateKey!)
        
        _apiManager.accountGet(State.currentServer!, account_address: account_address)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        State.currentVC = SegueTomultisigAccountManager
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row < _currentCosignatories.count + _addArray.count {
            let cell :MultisigSignerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cosig cell")! as! MultisigSignerTableViewCell
            cell.infoLabel.numberOfLines = 2
            cell.editDelegate = self
            cell.isEditable = (_removeArray.count == 0 && (_removeArray.count + _addArray.count) < 16)  && !self._isMultisig
            
            var index = 0
            if (indexPath as NSIndexPath).row >= _currentCosignatories.count {
                index = (indexPath as NSIndexPath).row - _currentCosignatories.count
                
                if index < _addArray.count {
                    cell.infoLabel.text =  AddressGenerator.generateAddress(_addArray[index]).nemName()
                }
                
            } else {
                cell.infoLabel.text = AddressGenerator.generateAddress(_currentCosignatories[(indexPath as NSIndexPath).row]).nemName()
            }
            
            return cell
        } else {
            let index = (indexPath as NSIndexPath).row - _currentCosignatories.count - _addArray.count
            
            switch index {
            case 0:
                let cell :UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "add cosig cell")!
                return cell
                
            case 1:
                let cell :MultisigMinimumSignerAmountTableViewCell = tableView.dequeueReusableCell(withIdentifier: "min cosig cell") as! MultisigMinimumSignerAmountTableViewCell
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
                let cell :UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "save cell")!
                return cell
                
            default :
                let cell :UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "add cosig cell")!
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row >= _addArray.count + _currentCosignatories.count {
            _addCosig()
        }
    }
    
    func deleteCell(_ cell: EditableTableViewCell) {
        var index = (tableView.indexPath(for: cell)! as NSIndexPath).row
        
        if index >= _currentCosignatories.count {
            index = index - _currentCosignatories.count
            _addArray.remove(at: index)
        } else {
            _removeArray.append(_currentCosignatories[index])
            _currentCosignatories.remove(at: index)
        }
        
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func saveChanges(_ sender: AnyObject) {
        
//        if _removeArray.count > 1 {
//            _showPopUp( "MULTISIG_REMOVE_COUNT_ERROR".localized())
//        }
//        else if (_currentCosignatories.count + _addArray.count) > 16 {
//            _showPopUp( "MULTISIG_COSIGNATORIES_COUNT_ERROR".localized())
//        }
//        else {
//            var fee = 10 + 6 * Int64(_addArray.count + _removeArray.count)
//            
//            var relativeChange = 0
//            
//            if self.minCosig != nil {
//                relativeChange = minCosig! - _activeAccount!.minCosignatories!
//            } else if _removeArray.count > 0 && (_activeAccount!.minCosignatories ?? 0) != 0 {
//                relativeChange = min( _activeAccount!.minCosignatories!, _activeAccount!.cosignatories.count - _removeArray.count) - _activeAccount!.minCosignatories!
//            }
//            
//            if relativeChange != 0{
//                fee += 6
//            }
//            
//            let transaction :AggregateModificationTransaction = AggregateModificationTransaction()
//            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
//            let publickey = self._activeAccount!.publicKey ?? KeyGenerator.generatePublicKey(privateKey!)
//            
//            transaction.timeStamp = TimeSynchronizator.nemTime
//            transaction.deadline = TimeSynchronizator.nemTime + waitTime
//            transaction.version = 2
//            transaction.signer = publickey
//            transaction.privateKey = privateKey
//            transaction.minCosignatory = relativeChange
//            
//            for publickey in _sortModifications(self._addArray) {
//                transaction.addModification(1, publicKey: publickey)
//            }
//            
//            for publickey in _sortModifications(self._removeArray)
//            {
//                transaction.addModification(2, publicKey: publickey)
//            }
//            
//            transaction.fee = Double(fee)
//            
//            self._apiManager.prepareAnnounce(State.currentServer!, transaction: transaction)
//        }
    }
    
    
    //MARK: - @IBAction
    
    @IBAction func minCosigChaned(_ sender: UITextField) {
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
    
//    @IBAction func chouseAccount(sender: AnyObject) {
//        if _popUp != nil {
//            _popUp!.view.removeFromSuperview()
//            _popUp!.removeFromParentViewController()
//            _popUp = nil
//            return
//        }
//        
//        if (_mainAccount?.cosignatoryOf ?? []).isEmpty {
//            return
//        }
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let accounts :AccountChooserViewController =  storyboard.instantiateViewControllerWithIdentifier("AccountChooserViewController") as! AccountChooserViewController
//        
//        accounts.view.frame = tableView.frame
//        
//        accounts.view.layer.opacity = 0
////        accounts.delegate = self
//        
//        var wallets = _mainAccount?.cosignatoryOf ?? []
//        
//        if _mainAccount != nil
//        {
//            wallets.append(self._mainAccount!)
//        }
//        accounts.wallets = wallets
//        
//        if accounts.wallets.count > 0
//        {
//            _popUp = accounts
//            self.view.addSubview(accounts.view)
//            
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                accounts.view.layer.opacity = 1
//                }, completion: nil)
//        }
//    }
    
    //MARK: - Private Methods
    
    fileprivate func _addCosig() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popUp :MultisigAddSignerViewController =  storyboard.instantiateViewController(withIdentifier: "MultisignatureAddSignerViewController") as! MultisigAddSignerViewController
        popUp.view.frame = CGRect(x: 0, y: 40, width: popUp.view.frame.width, height: popUp.view.frame.height - 40)
        popUp.view.layer.opacity = 0
//        popUp.delegate = self
        
        _popUp = popUp
        self.view.addSubview(popUp.view)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            popUp.view.layer.opacity = 1
            }, completion: nil)
    }
    
    fileprivate func _generateTableData() {
        var newCosigList :[String] = []
        
        for cosig in _activeAccount!.cosignatories {
            newCosigList.append(cosig.publicKey ?? "NO_PUBLICKEY".localized() )
        }
        
        _currentCosignatories = newCosigList
        _addArray = []
        _removeArray = []
        
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    fileprivate func _sortModifications(_ modifications :[String]) -> [String] {
        var resutModifications = modifications
//        for var sorted = false ; !sorted; {
//            sorted = true
//            for i in 1 ..< resutModifications.count {
//                let previousAddress = AddressGenerator.generateAddress(resutModifications[i-1])
//                let currentAddress = AddressGenerator.generateAddress(resutModifications[i])
//                
//                if previousAddress.compare(currentAddress) == ComparisonResult.orderedDescending {
//                    let mod = resutModifications[i]
//                    resutModifications[i] = resutModifications[i-1]
//                    resutModifications[i-1] = mod
//                    sorted = false
//                }
//            }
//        }
        return resutModifications
    }
    
    fileprivate final func _showPopUp(_ message :String){
        
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) {
            alertAction -> Void in
        }
        
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - AccountChousePopUp Methods

    func addCosig(_ publicKey: String) {
        _addArray.append(publicKey)
        tableView.reloadData()
    }
    
    //MARK: - AccountChousePopUp Methods
    
    func didChouseAccount(_ account: AccountGetMetaData) {
        
        if _popUp != nil {
            _popUp!.view.removeFromSuperview()
            _popUp!.removeFromParentViewController()
            _popUp = nil
        }
        _activeAccount = nil
        _apiManager.accountGet(State.currentServer!, account_address: account.address)
    }

    //MARK: - APIManagerDelegate Methods
    
    func accountGetResponceWithAccount(_ account: AccountGetMetaData?) {
        chouseButton.setTitle(account!.address.nemName(), for: UIControlState())
        accountLabel.text = account!.address.nemName()

        if account != nil {
            if _mainAccount == nil {
                if account!.cosignatoryOf.count > 0 {
                    chouseButton.isHidden = false
                    accountLabel.isHidden = true
                } else {
                    chouseButton.isHidden = true
                    accountLabel.isHidden = false
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
    
    func prepareAnnounceResponceWithTransactions(_ data: [TransactionPostMetaData]?) {
        
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
    
    func failWithError(_ message: String) {
        _showPopUp(message.localized())
    }
}
