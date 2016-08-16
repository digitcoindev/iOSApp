//
//  TransactionOverviewViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Moya
import GCDKit
import SwiftyJSON
import Contacts

/**
    The view controller that shows an overview of all transactions
    for the account that the user has chosen on the account list view
    controller.
 */
class TransactionOverviewViewController: UIViewController {
    
    // MARK: - View Controller Properties

    var account: Account?
    private var accountData: AccountData?
    private var transactions = [Transaction]()
    private var correspondents = [Correspondent]()
    
    
    private var _displayList :NSArray = NSArray()
    private var _requestsLimit: Int = 2
    private var _transactionsLimit: Int = 50
    private var _showUnconfirmed = true
    private var _requestCounter = 0
//    private var _timer: NSTimer? = nil
    
    private var _transactions:[_TransferTransaction] = []
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoHeaderLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tbc = tabBarController as? AccountDetailTabBarController {
            account = tbc.account
        }
        
        infoHeaderLabel.text = "NO_INTERNET_CONNECTION".localized()
        
        _displayList = correspondents
        
        fetchAccountData(forAccount: account!)
        fetchAllTransactions(forAccount: account!)

        
//            self.refreshTransactionList()
//            if AddressBookManager.isAllowed ?? false {
//                self.findCorrespondentName()
//            }
        
        
//        if let server = State.currentServer {
//            _apiManager.timeSynchronize(server)
//        }
        
//        _timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(updateInterval), target: self, selector: #selector(TransactionOverviewViewController.refreshTransactionList), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        updateViewControllerAppearance()
        createBarButtonItem()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        _timer?.invalidate()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        tabBarController?.title = "MESSAGES".localized()
    }
    
    /// Creates and adds the compose bar button item to the view controller.
    private func createBarButtonItem() {
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(segueToTransactionSendViewController))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        rightBarButtonItem.enabled = false
        
        tabBarController?.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    /**
        Updates the status of the compose bar button item according to the fetched
        account data. Enables the compose bar button item if the account isn't a 
        multisig account and disables the button if the account is a multisig account.
     
        - Parameter accountData: The fetched account data. Used to determine if the account is a multisig account.
     */
    private func updateBarButtonItemStatus(withAccountData accountData: AccountData) {
        
        if accountData.cosignatories.count > 0 {
            self.tabBarController?.navigationItem.rightBarButtonItem!.enabled = false
        } else {
            self.tabBarController?.navigationItem.rightBarButtonItem!.enabled = true
        }
    }
    
    /**
        Updates the info header label with the fetched account data (balance). Provide nil 
        as the account data to show a error message inside the info header label.
     
        - Parameter accountData: The fetched account data including the balance for the account. If this parameter doesn't get provided, the info header label will be updated with an error message.
     */
    private func updateInfoHeaderLabel(withAccountData accountData: AccountData?) {
        
        guard accountData != nil else {
            
            infoHeaderLabel.attributedText = NSMutableAttributedString(string: "LOST_CONNECTION".localized(), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
            
            return
        }
        
        let infoHeaderText = NSMutableAttributedString(string: "\(self.account!.title)")
        let infoHeaderTextBalance = " \((accountData!.balance / 1000000).format()) XEM"
        infoHeaderText.appendAttributedString(NSMutableAttributedString(string: infoHeaderTextBalance, attributes: [NSForegroundColorAttributeName : UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)]))
        
        infoHeaderLabel.attributedText = infoHeaderText
    }
    
    /**
        Fetches the account data (balance, cosignatories, etc.) for the current account from the active NIS.
        After a successful fetch the info header label gets updated with the account balance. The function
        also checks if the account is a multisig account and disables the compose bar button item accordingly.
     
        - Parameter account: The current account for which the account data should get fetched.
     */
    private func fetchAccountData(forAccount account: Account) {
        
        nisProvider.request(NIS.AccountData(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .Success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    
                    let accountData = try response.mapObject(AccountData)
                    
                    GCDQueue.Main.async {
                        
                        self?.updateBarButtonItemStatus(withAccountData: accountData)
                        self?.updateInfoHeaderLabel(withAccountData: accountData)
                        
                        self?.accountData = accountData
                    }
                    
                } catch {
                    
                    print("Failure: \(response.statusCode)")
                }
                
            case let .Failure(error):
                
                print(error)
                self?.updateInfoHeaderLabel(withAccountData: nil)
            }
        }
    }
    
    /**
 
     */
    private func fetchAllTransactions(forAccount account: Account) {
        
        nisProvider.request(NIS.AllTransactions(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .Success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var allTransactions = [Transaction]()
                    
                    for (_, subJson) in json["data"] {
                        
                        print(TransactionType(rawValue: subJson["transaction"]["type"].intValue))
                        
                        switch subJson["transaction"]["type"].intValue {
                        case TransactionType.TransferTransaction.rawValue:
                            
                            let transferTransaction = try subJson.mapObject(TransferTransaction)
                            allTransactions.append(transferTransaction)
                            
                        default:
                            return
                        }
                    }
                    
                    self?.transactions = allTransactions
                    self?.getCorrespondents(forTransactions: allTransactions)
                    
                } catch {
                    
                    print("Failure: \(response.statusCode)")
                }
                
            case let .Failure(error):
                
                print(error)
                self?.updateInfoHeaderLabel(withAccountData: nil)
            }
        }
    }
    
    /**
 
     */
    private func getCorrespondents(forTransactions transactions: [Transaction]) {
        
        var correspondents = [Correspondent]()
        
        for transaction in transactions {
            
            switch transaction.type {
            case .TransferTransaction:
                
                let transaction = transaction as! TransferTransaction
                let correspondent = Correspondent()
                
                if transaction.signer == account!.publicKey {
                    
                    correspondent.accountAddress = transaction.recipient
                    
                } else {
                    
                    correspondent.accountAddress = AccountManager.sharedInstance.generateAddress(forPublicKey: transaction.signer)
                }
                
                if correspondents.contains(correspondent) == false {
                    correspondents.append(correspondent)
                }
                
            default:
                return
            }
        }
        
        print("-------------")
        for correspondent in correspondents {
            print(correspondent.accountAddress)
        }
    }
    
//    final func accountTransfersAllResponceWithTransactions(data: [TransactionPostMetaData]?) {
//        if let data = data {
//            _requestCounter += 1
//            
//            if _requestCounter == 1 {
//                State.currentWallet?.lastTransactionHash = data.first?.hashString
////                CoreDataManager().commit()
//            }
//            
//            let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
//            let publicKey = KeyGenerator.generatePublicKey(privateKey!)
//            
//            for inData in data {
//                var innerTransaction :TransferTransaction? = nil
//                
//                switch (inData.type) {
//                case transferTransaction :
//                    innerTransaction = inData as? TransferTransaction
//                    
//                case multisigTransaction:
//                    
//                    let multisigT  = inData as! MultisigTransaction
//                    
//                    switch(multisigT.innerTransaction.type) {
//                    case transferTransaction :
//                        innerTransaction = multisigT.innerTransaction as? TransferTransaction
//                        
//                    default:
//                        break
//                    }
//                default:
//                    break
//                }
//                
//                if innerTransaction == nil {
//                    continue
//                }
//                
//                if innerTransaction!.signer != publicKey && innerTransaction!.recipient != self._account_address {
//                    continue
//                }
//                
//                _transactions.append(innerTransaction!)
//            }
//            
//            if data.count >= 25 && _requestCounter < _requestsLimit && _transactions.count <= _transactionsLimit{
//                _apiManager.accountTransfersAll(State.currentServer!, account_address: _account_address!, aditional: "&id=\(Int(data.last!.id))")
//            } else {
//                guard let server = State.currentServer else { return }
//                guard let address = walletData?.address else { return }
//                
//                _apiManager.unconfirmedTransactions(server, account_address: address)
//            }
//            
//        } else {
//            self.infoHeaderLabel.attributedText = NSMutableAttributedString(string: "LOST_CONNECTION".localized(), attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
//        }
//    }
    
//    final func unconfirmedTransactionsResponceWithTransactions(data: [TransactionPostMetaData]?) {
//        if let data = data {
//            
//            var needToSign = false
//
//            if data.count > 0 {
//                let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)
//                let publicKey = KeyGenerator.generatePublicKey(privateKey!)
//                
//                var addTransactions :[_TransferTransaction] = []
//                var transaction :_TransferTransaction? = nil
//
//                for inTransaction in data {
//                    
//                    switch inTransaction.type {
//                    case multisigTransaction:
//                        var findSignature = false
//
//                        let innerTransaction:TransactionPostMetaData = (inTransaction as! _MultisigTransaction).innerTransaction
//
//                        switch innerTransaction.type {
//                        case transferTransaction:
//                            if (innerTransaction as! _TransferTransaction).recipient == walletData?.address {
//                                findSignature = true
//                            }
//                            transaction = innerTransaction as? _TransferTransaction
//                        default:
//                            findSignature = true
//                            break
//                        }
//                        
//                        if (inTransaction as! _MultisigTransaction).signer == walletData!.publicKey || innerTransaction.signer == walletData!.publicKey {
//                            findSignature = true
//                        }
//                        
//                        for sign in (inTransaction as! _MultisigTransaction).signatures {
//                            if walletData!.publicKey == sign.signer {
//                                findSignature = true
//                            }
//                        }
//                        
//                        if !findSignature {
//                            needToSign = true
//                        }
//                        
//                    case transferTransaction:
//                        transaction = inTransaction as? _TransferTransaction
//                        
//                    default :
//                        break
//                    }
//                    
//                    if transaction == nil {
//                        continue
//                    }
//                    
//                    if transaction!.signer != publicKey && transaction!.recipient != self._account_address {
//                        continue
//                    }
//                    
//                    addTransactions.append(transaction!)
//
//                }
//                
//                _transactions = addTransactions + _transactions
//            }
//            
//            _correspondents = Correspondent.generateCorespondetsFromTransactions(_transactions)
//            _displayList = _correspondents
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                self.tableView.reloadData()
//                
//                if needToSign && self._showUnconfirmed {
//                    let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "UNCONFIRMED_TRANSACTIONS_DETECTED".localized(), preferredStyle: UIAlertControllerStyle.Alert)
//                    
//                    let ok :UIAlertAction = UIAlertAction(title: "SHOW_TRANSACTIONS".localized(), style: UIAlertActionStyle.Default) {
//                        alertAction -> Void in
//                        
//                        self.performSegueWithIdentifier("showTransactionUnconfirmedViewController", sender: nil)
//                    }
//                    
//                    let cancel :UIAlertAction = UIAlertAction(title: "REMIND_LATER".localized(), style: UIAlertActionStyle.Default) {
//                        alertAction -> Void in
//                        self._showUnconfirmed = false
//                    }
//                    
//                    alert.addAction(cancel)
//                    alert.addAction(ok)
//       
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//            })
//        }
//    }
    
    // MARK: - Help Methods
    
//    final func sort_correspondents(_correspondents :[Correspondent])->[Correspondent] {
//        var _correspondentsIn = _correspondents
//        var data :[CorrespondentCellData] = [CorrespondentCellData]()
//        
//        for correspondent in _correspondentsIn {
//            var value = CorrespondentCellData()
//            value.correspondent = correspondent
//            value.lastMessage = correspondent.transaction
//            data.append(value)
//        }
//        
//        for var index = 0 ; index < data.count ; index += 1 {
//            var sorted = true
//            
//            for var indexIN = 0 ; indexIN < data.count - 1 ; indexIN += 1 {
//                var firstValue :Int!
//                if data[indexIN].lastMessage != nil {
//                    firstValue = Int(data[indexIN].lastMessage!.id)
//                }
//                else {
//                    firstValue = -1
//                }
//                
//                var secondValue :Int!
//                if data[indexIN + 1].lastMessage != nil {
//                    secondValue = Int(data[indexIN + 1].lastMessage!.id)
//                }
//                else {
//                    secondValue = -1
//                }
//                
//                if firstValue < secondValue || (secondValue == -1 &&  secondValue != firstValue) {
//                    let accum = data[indexIN + 1]
//                    data[indexIN + 1] = data[indexIN]
//                    data[indexIN] = accum
//                    
//                    sorted = false
//                }
//            }
//            
//            if sorted {
//                break
//            }
//        }
//        
//        _correspondentsIn.removeAll(keepCapacity: false)
//        
//        for correspondent in data {
//            _correspondentsIn.append(correspondent.correspondent)
//        }
//        
//        return _correspondentsIn
//    }
    
//    final func findCorrespondentName() {
//        let contacts :NSArray = AddressBookManager.contacts
//        
//        for correspondent in _correspondents {
//            if correspondent.name.utf16.count > 20 {
//                var find = false
//                for contact in contacts {
//                    let emails: [CNLabeledValue] = contact.emailAddresses
//                    
//                    for email in emails {
//                        if email.label == "NEM" && email.value as! String == correspondent.address {
//                            correspondent.name = (contact.givenName ?? "") + " " + (contact.familyName ?? "")
//                            find = true
//                            break
//                        }
//                    }
//                    
//                    if find {
//                        break
//                    }
//                }
//            }
//        }
//    }
    
//    final func refreshTransactionList() {
//        if State.currentServer != nil && _account_address != nil {
//            _transactions = []
//            _requestCounter = 0
//            
//            _apiManager.accountGet(State.currentServer!, account_address: _account_address!)
//            _apiManager.accountTransfersAll(State.currentServer!, account_address: _account_address!)
//        }
//        else {
//            
//            performSegueWithIdentifier("showSettingsServerViewController", sender: nil)
//        }
//    }
    

    func segueToTransactionSendViewController() {
        
        performSegueWithIdentifier("showTransactionSendViewController", sender: nil)
    }
}

// MARK: - Table View Data Source

extension TransactionOverviewViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _displayList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : TransactionOverviewCorrespondentTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("correspondent") as! TransactionOverviewCorrespondentTableViewCell
//        let cellData  : Correspondent = _displayList[indexPath.row] as! Correspondent
//        let transaction :_TransferTransaction? = cellData.transaction
//        
//        cell.name.text = "  " + cellData.name
//        
//        if transaction != nil {
//            cell.message.text = transaction!.message.getMessageString() ?? "ENCRYPTED_MESSAGE".localized()
//        }
//        else {
//            cell.message.text = ""
//        }
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        var timeStamp = Double(transaction!.timeStamp )
//        
//        timeStamp += genesis_block_time
//        
//        if dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp)) == dateFormatter.stringFromDate(NSDate()) {
//            dateFormatter.dateFormat = "HH:mm"
//        }
//        
//        cell.date.text = ((transaction?.id == nil) ? ("UNCONFIRMED_DASHBOARD".localized() + " ") : "") + dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: timeStamp))
//        
//        var color :UIColor!
//        var vector :String = ""
//        if transaction?.recipient != _account_address! {
//            color = UIColor.redColor()
//            vector = "-"
//        } else if AddressGenerator.generateAddress(transaction!.signer) ==  _account_address {
//            color = UIColor(red: 142 / 255, green: 142 / 255, blue: 142 / 255, alpha: 1)
//            vector = "±"
//        } else {
//            color = UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)
//            vector = "+"
//        }
//        
//        let attribute = [NSForegroundColorAttributeName : color]
//        
//        let amount = vector + "\((transaction!.amount / 1000000).format()) XEM"
//        
//        cell.xems.attributedText = NSMutableAttributedString(string: amount, attributes: attribute)
        
        return cell
    }
}

// MARK: - Table View Delegate

extension TransactionOverviewViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if accountData != nil {
            State.invoice = nil
            
            //            var nextVC = ""
            if accountData!.cosignatories.count > 0 {
                performSegueWithIdentifier("showTransactionMultisignatureMessagesViewController", sender: nil)
            }
            else if accountData!.cosignatoryOf.count > 0 {
                performSegueWithIdentifier("showTransactionCosignatoryMessagesViewController", sender: nil)
                
            } else {
                performSegueWithIdentifier("showTransactionNormalMessagesViewController", sender: nil)
            }
        }
        else {
            self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
    }
}
