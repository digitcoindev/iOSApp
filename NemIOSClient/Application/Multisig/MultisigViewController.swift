//
//  MultisigViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import SwiftyJSON

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

/// The view controller that lets the user manage multisig for the account.
class MultisigViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    fileprivate var account: Account?
    fileprivate var accountData: AccountData?
    fileprivate var activeAccountData: AccountData?
    fileprivate var accountChooserViewController: UIViewController?
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var multisigAccountChooserButton: AccountChooserButton!
    @IBOutlet weak var minCosigField: NEMTextField!
    @IBOutlet weak var infoHeaderLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountManager.sharedInstance.activeAccount
        
        guard account != nil else {
            print("Critical: Account not available!")
            return
        }
        
        showLoadingView()
        updateViewControllerAppearance()
        
        fetchAccountData(forAccount: account!)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    fileprivate func updateViewControllerAppearance() {
        
        title = "MULTISIG".localized()
    }
    
    /**
        Updates the info header label with the fetched account data.
     
        - Parameter accountData: The fetched account data for the account.
     */
    fileprivate func updateInfoHeaderLabel(withAccountData accountData: AccountData?) {
        
        guard accountData != nil else {
            infoHeaderLabel.attributedText = NSMutableAttributedString(string: "LOST_CONNECTION".localized(), attributes: [NSForegroundColorAttributeName : UIColor.red])
            return
        }
        
        let accountTitle = accountData!.title != nil ? accountData!.title! : accountData!.address.nemAddressNormalised()
        let infoHeaderText = NSMutableAttributedString(string: "\(accountTitle)")
        infoHeaderLabel.attributedText = infoHeaderText
    }
    
    /**
        Updates the multisig account chooser button title with the fetched account data.
     
        - Parameter accountData: The fetched account data for the account.
     */
    fileprivate func updateAccountChooserButtonTitle(withAccountData accountData: AccountData?) {
        
        guard accountData != nil else {
            multisigAccountChooserButton.setTitle("LOST_CONNECTION".localized(), for: .normal)
            return
        }
        
        let accountTitle = accountData!.title != nil ? accountData!.title! : accountData!.address.nemAddressNormalised()
        multisigAccountChooserButton.setTitle(accountTitle, for: .normal)
    }
    
    /**
        Shows the loading view above the table view which shows
        an spinning activity indicator.
     */
    fileprivate func showLoadingView() {
        
        loadingActivityIndicator.startAnimating()
        loadingView.isHidden = false
    }
    
    /// Hides the loading view.
    fileprivate func hideLoadingView() {
        
        loadingView.isHidden = true
        loadingActivityIndicator.stopAnimating()
    }
    
    /**
        Fetches the account data (balance, cosignatories, etc.) for the current account from the active NIS.
     
        - Parameter account: The current account for which the account data should get fetched.
     */
    fileprivate func fetchAccountData(forAccount account: Account) {
        
        nisProvider.request(NIS.accountData(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let accountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        self?.accountData = accountData
                        self?.activeAccountData = accountData
                        
                        if self?.accountData?.cosignatoryOf.count > 0 {
                            
                            self?.multisigAccountChooserButton.isHidden = false
                            self?.infoHeaderLabel.isHidden = true
                            
                            self?.updateAccountChooserButtonTitle(withAccountData: accountData)
                            
                        } else {
                            
                            self?.multisigAccountChooserButton.isHidden = true
                            self?.infoHeaderLabel.isHidden = false
                            
                            self?.updateInfoHeaderLabel(withAccountData: accountData)
                        }
                        
                        self?.tableView.reloadData()
                        self?.hideLoadingView()
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        
                        print("Failure: \(response.statusCode)")
                    }
                }
                
            case let .failure(error):
                
                DispatchQueue.main.async {
                    
                    print(error)
                }
            }
        }
    }
    
    /**
        Fetches the account data (balance, cosignatories, etc.) for the current account from the active NIS.
     
        - Parameter accountData: The current account for which the account data should get fetched.
     */
    fileprivate func fetchAccountData(forAccount accountData: AccountData) {
        
        nisProvider.request(NIS.accountData(accountAddress: accountData.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let accountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        self?.activeAccountData = accountData
                        
                        if self?.accountData?.cosignatoryOf.count > 0 {
                            
                            self?.multisigAccountChooserButton.isHidden = false
                            self?.infoHeaderLabel.isHidden = true
                            
                            self?.updateAccountChooserButtonTitle(withAccountData: accountData)
                            
                        } else {
                            
                            self?.multisigAccountChooserButton.isHidden = true
                            self?.infoHeaderLabel.isHidden = false
                            
                            self?.updateInfoHeaderLabel(withAccountData: accountData)
                        }
                        
                        self?.tableView.reloadData()
                        self?.hideLoadingView()
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        
                        print("Failure: \(response.statusCode)")
                    }
                }
                
            case let .failure(error):
                
                DispatchQueue.main.async {
                    
                    print(error)
                }
            }
        }
    }
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func chooseAccount(_ sender: UIButton) {
        
        if accountChooserViewController == nil {
            
            var accounts = accountData!.cosignatoryOf ?? []
            accounts.append(accountData!)
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let accountChooserViewController = mainStoryboard.instantiateViewController(withIdentifier: "AccountChooserViewController") as! AccountChooserViewController
            accountChooserViewController.view.frame = CGRect(x: tableView.frame.origin.x, y:  tableView.frame.origin.y, width: tableView.frame.width, height: tableView.frame.height)
            accountChooserViewController.view.layer.opacity = 0
            accountChooserViewController.delegate = self
            accountChooserViewController.accounts = accounts
            
            self.accountChooserViewController = accountChooserViewController
            
            if accounts.count > 0 {
                view.addSubview(accountChooserViewController.view)
                
                UIView.animate(withDuration: 0.2, animations: {
                    accountChooserViewController.view.layer.opacity = 1
                })
            }
            
        } else {
            
            accountChooserViewController!.view.removeFromSuperview()
            accountChooserViewController!.removeFromParentViewController()
            accountChooserViewController = nil
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
    
    @IBAction func minCosigChaned(_ sender: UITextField) {
//        var isNormal = false
//        print()
//        if let value = Int(sender.text!) {
//            if value >= minCosigValue && value <= maxCosigValue {
//                isNormal = true
//                self.minCosig = value
//                sender.text = ""
//                let currentValue = (_activeAccount!.minCosignatories == 0 || _activeAccount!.minCosignatories == _activeAccount!.cosignatories.count) ? _activeAccount!.cosignatories.count - _removeArray.count : _activeAccount!.minCosignatories!
//
//                if currentValue == value {
//                    sender.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER".localized()), "\(value)")
//                } else {
//                    sender.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER_CHANGED".localized()), "\(value)")
//                }
//            }
//        }
//        
//        if !isNormal {
//            sender.text = ""
//            self.minCosig = nil
//            if let minCosignatories = _activeAccount!.minCosignatories {
//                let currentValue = (minCosignatories == 0 || minCosignatories == _activeAccount!.cosignatories.count) ? _activeAccount!.cosignatories.count - _removeArray.count : minCosignatories
//                
//                sender.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER".localized()), "\(currentValue)")
//            }
//        } else {
//            self.tableView.reloadData()
//        }
    }
    
    /**
        Unwinds to the account list view controller and reloads all
        accounts to show.
     */
    @IBAction func unwindToMultisigViewController(_ segue: UIStoryboardSegue) {
        
        tableView.reloadData()
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
    
    func addCosig(_ publicKey: String) {
//        _addArray.append(publicKey)
//        tableView.reloadData()
    }
    
    func prepareAnnounceResponceWithTransactions(_ data: [TransactionPostMetaData]?) {
        
//        var message :String = ""
//        
//        minCosig = nil
//        _addArray = []
//        _removeArray = []
//        
//        self.tableView.reloadData()
//        
//        if !(data ?? []).isEmpty {
//            message = "TRANSACTION_ANOUNCE_SUCCESS".localized()
//            _showPopUp(message)
//        }
    }
    
    func failWithError(_ message: String) {
//        _showPopUp(message.localized())
    }
}

// MARK: - Table View Delegate

extension MultisigViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let activeAccountData = activeAccountData {
            if activeAccountData.cosignatories.count > 0 {
                if accountData == activeAccountData {
                    
                    return activeAccountData.cosignatories.count
                    
                } else {
                    
                    return activeAccountData.cosignatories.count + 2
                }
                
            } else {
                
                return 1
            }
            
        } else {
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if activeAccountData?.cosignatories.count > 0 {
            if accountData == activeAccountData {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MultisigSignerTableViewCell") as! MultisigSignerTableViewCell
                cell.signerAccountData = activeAccountData!.cosignatories[indexPath.row]
                
                return cell
                
            } else {
                
                if indexPath.row < activeAccountData!.cosignatories.count {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MultisigSignerTableViewCell") as! MultisigSignerTableViewCell
                    cell.signerAccountData = activeAccountData!.cosignatories[indexPath.row]
                    
                    return cell
                    
                } else if indexPath.row == activeAccountData!.cosignatories.count {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MultisigAddSignerTableViewCell") as! MultisigAddSignerTableViewCell
                    
                    return cell
                    
                } else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "min cosig cell") as! MultisigMinimumSignerAmountTableViewCell
                    
                    let minCosignatories = (activeAccountData!.minCosignatories == 0 || activeAccountData!.minCosignatories == activeAccountData!.cosignatories.count) ? activeAccountData!.cosignatories.count : activeAccountData!.minCosignatories
                    let maxCosignatories = activeAccountData!.cosignatories.count
                    
                    cell.textField.placeholder = String(format: ("   " + "MIN_COSIG_PLACEHOLDER".localized()), "\(minCosignatories!)")
                                    
                    return cell
                }
            }
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultisigAddSignerTableViewCell") as! MultisigAddSignerTableViewCell
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == activeAccountData!.cosignatories.count {
            
            performSegue(withIdentifier: "showMultisigAddSignerViewController", sender: nil)
        }
    }
}

// MARK: - Account Chooser Delegate

extension MultisigViewController: AccountChooserDelegate {
    
    func didChooseAccount(_ accountData: AccountData) {
        
        activeAccountData = accountData
        
        accountChooserViewController?.view.removeFromSuperview()
        accountChooserViewController?.removeFromParentViewController()
        accountChooserViewController = nil
        
        fetchAccountData(forAccount: accountData)
    }
}
