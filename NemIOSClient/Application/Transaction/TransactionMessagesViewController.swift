//
//  TransactionMessagesViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import GCDKit
import SwiftyJSON

/**
    The view controller that shows all messages/transactions with the
    correspondent in detail.
 */
class TransactionMessagesViewController: UIViewController, UIAlertViewDelegate, AccountsChousePopUpDelegate, DetailedTableViewCellDelegate {
    
    // MARK: - View Controller Properties
    
    var account: Account?
    var correspondent: Correspondent?
    private var accountData: AccountData?
    private var transactions = [Transaction]()
    private var unconfirmedTransactions = [Transaction]()
    
    private var refreshTimer: NSTimer? = nil
    private let correspondentTransactionsDispatchGroup = GCDGroup()

    private var rowHeight = [CGFloat]()
    
    private var _accounts :[AccountGetMetaData] = []
    private var _mainAccount :AccountGetMetaData? = nil
    private var _activeAccount :AccountGetMetaData? = nil
    
    private var _isEnc = false
    
    private var _bottomInsert :CGFloat = 0
    
    private let rowLength :Int = 21
    
    private let greenColor :UIColor = UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)
    private let grayColor :UIColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)


    private var _popup :UIViewController? = nil
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoHeaderLabel: UILabel!
    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var transactionMessageTextField: UITextField!
    @IBOutlet weak var transactionEncryptionButton: UIButton!
    @IBOutlet weak var transactionSendButton: UIButton!
    @IBOutlet weak var transactionAccountChooserButton: UIButton!
    @IBOutlet weak var transactionAmountContainerView: UIView!

    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard account != nil else {
            print("Fatal error: Account nil")
            return
        }
        guard correspondent != nil else {
            print("Fatal error: Correspondent nil")
            return
        }
        
        updateViewControllerAppearance()
        createBarButtonItem()
        addKeyboardObserver()
        refreshCorrespondentTransactions()
//        startRefreshing()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        stopRefreshing()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller.
    private func updateViewControllerAppearance() {
        
        title = correspondent!.name != nil ? correspondent!.name : correspondent!.accountAddress.nemAddressNormalised()
        infoHeaderLabel.text = "NO_INTERNET_CONNECTION".localized()
        transactionAmountTextField.placeholder = "AMOUNT".localized()
        transactionMessageTextField.placeholder = "MESSAGE".localized()
        transactionSendButton.setTitle("SEND".localized(), forState: UIControlState.Normal)
        transactionAccountChooserButton.setTitle("ACCOUNTS".localized(), forState: UIControlState.Normal)
        
        transactionAccountChooserButton.layer.cornerRadius = 5
        transactionSendButton.layer.cornerRadius = 5
        transactionAmountContainerView.layer.cornerRadius = 5
        transactionAmountContainerView.clipsToBounds = true
        transactionMessageTextField.layer.cornerRadius = 5
    }
    
    /// Creates and adds the compose bar button item to the view controller.
    private func createBarButtonItem() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(copyCorrespondentAddress(_:)))
    }
    
    /// Adds all needed keyboard observers to the view controller.
    private func addKeyboardObserver() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TransactionMessagesViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TransactionMessagesViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /// Updates the position of all elements if the keyboard appears.
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if self.view.frame.origin.y == 64.0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    /// Updates the position of all elements if the keyboard disappears.
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
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
        
        let infoHeaderText = NSMutableAttributedString(string: "\(self.account!.title) ·")
        let infoHeaderTextBalance = " \((accountData!.balance / 1000000).format()) XEM"
        infoHeaderText.appendAttributedString(NSMutableAttributedString(string: infoHeaderTextBalance, attributes: [NSForegroundColorAttributeName: UIColor(red: 90.0/255.0, green: 179.0/255.0, blue: 232.0/255.0, alpha: 1), NSFontAttributeName: UIFont.systemFontOfSize(infoHeaderLabel.font.pointSize, weight: UIFontWeightRegular)]))
        
        infoHeaderLabel.attributedText = infoHeaderText
    }
    
    /// Starts refreshing the transaction overview in the defined interval.
    private func startRefreshing() {
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(updateInterval), target: self, selector: #selector(TransactionMessagesViewController.refreshCorrespondentTransactions), userInfo: nil, repeats: true)
    }
    
    /// Stops refreshing the transaction overview.
    private func stopRefreshing() {
        refreshTimer?.invalidate()
    }

    /**
        Updates the correspondent transactions table view in an asynchronous manner.
        Fires off all necessary network calls to get the information needed.
        Use only this method to update the displayed information.
     */
    func refreshCorrespondentTransactions() {
        
        fetchAccountData(forAccount: account!)
        fetchAllTransactions(forAccount: account!)
        fetchUnconfirmedTransactions(forAccount: account!)
        
        correspondentTransactionsDispatchGroup.notify(.Main) {
            self.getTransactionsForCorrespondent(fromTransactions: &self.transactions)
            self.getTransactionsForCorrespondent(fromTransactions: &self.unconfirmedTransactions)
            
            self._heightForCell(self.transactions, width: self.tableView.frame.width - 120)
            self.rowHeight.append(CGFloat())
            self._heightForCell(self.unconfirmedTransactions, width: self.tableView.frame.width - 120)
            
            self.tableView.reloadData()
            self.scrollToTableBottom()
        }
    }
    
    /**
        Fetches the account data (balance, cosignatories, etc.) for the current account from the active NIS.
        After a successful fetch the info header label gets updated with the account balance. The function
        also checks if the account is a multisig account and disables the compose bar button item accordingly.
        Do not call this function directly. Use the method refreshCorrespondentTransactions.
     
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
                        
                        self?.updateInfoHeaderLabel(withAccountData: accountData)
                        
                        self?.accountData = accountData
                    }
                    
                } catch {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")
                    }
                }
                
            case let .Failure(error):
                
                GCDQueue.Main.async {
                    
                    print(error)
                    self?.updateInfoHeaderLabel(withAccountData: nil)
                }
            }
        }
    }
    
    /**
        Fetches the last 25 transactions for the current account from the active NIS.
        Do not call this function directly. Use the method refreshCorrespondentTransactions.
     
        - Parameter account: The current account for which the transactions should get fetched.
     */
    private func fetchAllTransactions(forAccount account: Account) {
        
        correspondentTransactionsDispatchGroup.enter()
        
        nisProvider.request(NIS.AllTransactions(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .Success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var allTransactions = [Transaction]()
                    
                    for (_, subJson) in json["data"] {
                        
                        switch subJson["transaction"]["type"].intValue {
                        case TransactionType.TransferTransaction.rawValue:
                            
                            let transferTransaction = try subJson.mapObject(TransferTransaction)
                            allTransactions.append(transferTransaction)
                            
                        case TransactionType.MultisigTransaction.rawValue:
                            
                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
                            case TransactionType.TransferTransaction.rawValue:
                                
                                let multisigTransaction = try subJson.mapObject(MultisigTransaction)
                                let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction
                                allTransactions.append(transferTransaction)
                                
                            default:
                                break
                            }
                            
                        default:
                            break
                        }
                    }
                    
                    GCDQueue.Main.async {
                        
                        self?.transactions = allTransactions
                        
                        self?.correspondentTransactionsDispatchGroup.leave()
                    }
                    
                } catch {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")
                        
                        self?.correspondentTransactionsDispatchGroup.leave()
                    }
                }
                
            case let .Failure(error):
                
                GCDQueue.Main.async {
                    
                    print(error)
                    self?.updateInfoHeaderLabel(withAccountData: nil)
                    
                    self?.correspondentTransactionsDispatchGroup.leave()
                }
            }
        }
    }
    
    /**
        Fetches all unconfirmed transactions for the provided account.
        Do not call this function directly. Use the method refreshCorrespondentTransactions.
     
        - Parameter account: The account for which all unconfirmed transaction should get fetched.
     */
    private func fetchUnconfirmedTransactions(forAccount account: Account) {
        
        correspondentTransactionsDispatchGroup.enter()
        
        nisProvider.request(NIS.UnconfirmedTransactions(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .Success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var unconfirmedTransactions = [Transaction]()
                    
                    for (_, subJson) in json["data"] {
                        
                        switch subJson["transaction"]["type"].intValue {
                        case TransactionType.TransferTransaction.rawValue:
                            
                            let transferTransaction = try subJson.mapObject(TransferTransaction)
                            unconfirmedTransactions.append(transferTransaction)
                            
                        case TransactionType.MultisigTransaction.rawValue:
                            
                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
                            case TransactionType.TransferTransaction.rawValue:
                                
                                let multisigTransaction = try subJson.mapObject(MultisigTransaction)
                                let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction
                                unconfirmedTransactions.append(transferTransaction)
                                
                            default:
                                break
                            }
                            
                        default:
                            break
                        }
                    }
                    
                    GCDQueue.Main.async {
                        
                        self?.unconfirmedTransactions = unconfirmedTransactions
                        
                        self?.correspondentTransactionsDispatchGroup.leave()
                    }
                    
                } catch {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")
                        
                        self?.correspondentTransactionsDispatchGroup.leave()
                    }
                }
                
            case let .Failure(error):
                
                GCDQueue.Main.async {
                    
                    print(error)
                    self?.updateInfoHeaderLabel(withAccountData: nil)
                    
                    self?.correspondentTransactionsDispatchGroup.leave()
                }
            }
        }
    }
    
    /**
        Filters out all transaction in connection with the current correspondent and populates the
        table view with that information. Do not call this function directly. Use the method refreshTransactionOverview.
     
        - Parameter transactions: The transactions which should get fitered.
     */
    private func getTransactionsForCorrespondent(inout fromTransactions transactions: [Transaction]) {
        
        var correspondentTransactions: [Transaction] = [TransferTransaction]()
        
        for transaction in transactions {
            
            switch transaction.type {
            case .TransferTransaction:
                
                let transaction: TransferTransaction = transaction as! TransferTransaction
                
                if correspondent?.accountAddress != account?.address {
                    
                    if AccountManager.sharedInstance.generateAddress(forPublicKey: transaction.signer) == correspondent?.accountAddress {
                        transaction.transferType = .Incoming
                        correspondentTransactions.append(transaction)
                    } else if transaction.recipient == correspondent?.accountAddress {
                        transaction.transferType = .Outgoing
                        correspondentTransactions.append(transaction)
                    }
                    
                } else {
                    
                    if transaction.recipient == account?.address && transaction.recipient == AccountManager.sharedInstance.generateAddress(forPublicKey: transaction.signer) {
                        
                        transaction.transferType = .Incoming
                        correspondentTransactions.append(transaction)
                    }
                }

            default:
                break
            }
        }
        
        correspondentTransactions.sortInPlace({ $0.timeStamp < $1.timeStamp })
        
        transactions = correspondentTransactions
    }
    
    /// Scrolls to the bottom of the table view.
    func scrollToTableBottom() {
        
        if tableView.contentSize.height > tableView.frame.size.height {
            let offset = CGPointMake(0, tableView.contentSize.height - tableView.frame.size.height)
            tableView.setContentOffset(offset, animated: false)
        }
    }
    
//    final func defineData() {
//        //let publicKey :String = KeyGenerator.generatePublicKey(HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!)
//        var data :[DefinedCell] = []
//        
//        for transaction in _transactions {
//            var definedCell : DefinedCell = DefinedCell()
//            definedCell.type = .Outgoing
//            
//            let innertTransaction = (transaction.type == multisigTransaction) ? ((transaction as! _MultisigTransaction).innerTransaction as! _TransferTransaction) :
//                (transaction as! _TransferTransaction)
//            
//            if (innertTransaction.recipient == _account_address) {
//                definedCell.type = .Incoming
//            }
//            
////            innertTransaction.message.signer = contact.public_key
//            var message :NSMutableAttributedString = NSMutableAttributedString(string: innertTransaction.message.getMessageString() ?? "COULD_NOT_DECRYPT".localized(), attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: textSizeCommon)!])
//            
//            if(innertTransaction.amount > 0) {
//                var text :String = " \((innertTransaction.amount / 1000000).format()) XEM"
//                if message != ""
//                {
//                    text = "\n" + text
//                }
//                
//                let messageXEMS :NSMutableAttributedString = NSMutableAttributedString(string:text , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeXEM)! ])
//                message.appendAttributedString(messageXEMS)
//            }
//            
//            message = (message.length == 0) ? NSMutableAttributedString(string: "EMPTY_MESSAGE".localized(), attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Italic", size: textSizeCommon)! ]) : message
//            
//            definedCell.height = _heightForCell(message, width: tableView.frame.width - 120) + 20
//            
//            message = NSMutableAttributedString(string: "BLOCK".localized() + ": " , attributes: nil)
//            message.appendAttributedString(NSMutableAttributedString(string:"\(innertTransaction.height.format())" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 10)! ]))
//            definedCell.detailsTop = message
//            
//            message = NSMutableAttributedString(string: "FEE".localized() + ": " , attributes: nil)
//            message.appendAttributedString(NSMutableAttributedString(string:"\((innertTransaction.fee / 1000000).format())" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 10)! ]))
//            
//            definedCell.detailsMiddle = message
//            
//            data.append(definedCell)
//        }
//        
//        for transaction in _unconfirmedTransactions {
//            var definedCell : DefinedCell = DefinedCell()
//            definedCell.type = .Processing
//            
//            let innertTransaction = (transaction.type == multisigTransaction) ? ((transaction as! _MultisigTransaction).innerTransaction as! _TransferTransaction) :
//                (transaction as! _TransferTransaction)
////            innertTransaction.message.signer = contact.public_key
//            
//            var message :NSMutableAttributedString = NSMutableAttributedString(string: innertTransaction.message.getMessageString() ?? "COULD_NOT_DECRYPT".localized() , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: textSizeCommon)!])
//            
//            if(innertTransaction.amount != 0) {
//                var text :String = "\((innertTransaction.amount / 1000000).format()) XEM"
//                if message != ""
//                {
//                    text = "\n" + text
//                }
//                
//                let messageXEMS :NSMutableAttributedString = NSMutableAttributedString(string:text , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: textSizeXEM)! ])
//                message.appendAttributedString(messageXEMS)
//            }
//            
//            message = (message.length == 0) ? NSMutableAttributedString(string: "EMPTY_MESSAGE".localized(), attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Italic", size: textSizeCommon)! ]) : message
//            
//            definedCell.height =  max(_heightForCell(message, width: tableView.frame.width - 120), CGFloat(80))
//            
//            
//            if transaction.type == multisigTransaction {
//                definedCell.minCosignatories = _getMinCosigFor(transaction as! _MultisigTransaction)
//            }
//            
//            if transaction.type == multisigTransaction {
//                let signerAdress = AddressGenerator.generateAddress(innertTransaction.signer)
//                let singnaturesCount = (transaction as! _MultisigTransaction).signatures.count + 1
//                var cosignatories = 0
//                var minCosig = 0
//                
//                for account in _accounts {
//                    if account.address == signerAdress {
//                        minCosig = account.minCosignatories!
//                        cosignatories = account.cosignatories.count
//                        break
//                    }
//                }
//                let attribute = [NSForegroundColorAttributeName : greenColor]
//                
//                message = NSMutableAttributedString(string:"\(singnaturesCount)" , attributes: attribute)
//                message.appendAttributedString(NSMutableAttributedString(string: " " + "OF".localized() + " ", attributes: nil))
//                message.appendAttributedString(NSMutableAttributedString(string:"\(cosignatories) " , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 10)! ]))
//                message.appendAttributedString(NSMutableAttributedString(string:"SIGNERS".localized() , attributes: nil))
//                
//                definedCell.detailsTop = message
//                
//                message = NSMutableAttributedString(string:"MIN".localized() + " " , attributes: nil)
//                message.appendAttributedString(NSMutableAttributedString(string:"\(((minCosig == 0) ? cosignatories : minCosig))" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 10)! ]))
//                message.appendAttributedString(NSMutableAttributedString(string:" " + "SIGNERS".localized() , attributes: nil))
//                
//                definedCell.detailsMiddle = message
//                
//                message = NSMutableAttributedString(string: "FEE".localized() + ": " , attributes: nil)
//                message.appendAttributedString(NSMutableAttributedString(string:"\((innertTransaction.fee / 1000000).format())" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 10)! ]))
//                
//                definedCell.detailsBottom = message
//            } else {
//                message = NSMutableAttributedString(string: "FEE".localized() + ": " , attributes: nil)
//                message.appendAttributedString(NSMutableAttributedString(string:"\((innertTransaction.fee / 1000000).format())" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 10)! ]))
//                
//                definedCell.detailsMiddle = message
//            }
//            
//            data.append(definedCell)
//        }
//        
//        var removeCount = 0
//        var addCount = _transactions.count - _completed
//        
//        if self.tableView.numberOfRowsInSection(0) == 0 && (addCount > 0 || _unconfirmedTransactions.count > 0){
//            addCount += 1
//        }
//        
//        removeCount = (_unconfirmed > 0) ? _unconfirmed + 1 : 0
//        addCount += (_unconfirmedTransactions.count > 0) ? _unconfirmedTransactions.count + 1 : 0
//        
//        _completed = _transactions.count
//        _unconfirmed = _unconfirmedTransactions.count
//        _definedCells = data
//        
//        dispatch_async(dispatch_get_main_queue() , {
//            () -> Void in
//            
//            var actionArray :[NSIndexPath] = []
//            var rowsCount = self.tableView.numberOfRowsInSection(0)
//            
//            for var i = self.tableView.numberOfRowsInSection(0) - removeCount ; 0 < removeCount && addCount > 0 ;i += 1 {
//                print("update \(i)")
//                actionArray.append(NSIndexPath(forRow: i, inSection: 0))
//                removeCount -= 1
//                addCount -= 1
//            }
//            
//            self.tableView.beginUpdates()
//            
//            if actionArray.count > 0 {
//                self.tableView.reloadRowsAtIndexPaths(actionArray, withRowAnimation: UITableViewRowAnimation.None)
//            }
//            
//            actionArray = []
//            
//            for var i = 0 ; i < removeCount && (rowsCount - 1 - i > 0) ;i += 1 {
//                print("delete \(rowsCount - 1 - i)")
//                actionArray.append(NSIndexPath(forRow: rowsCount - 1 - i, inSection: 0))
//            }
//            if actionArray.count > 0 {
//                self.tableView.deleteRowsAtIndexPaths(actionArray, withRowAnimation: UITableViewRowAnimation.Left)
//            }
//            
//            actionArray = []
//            rowsCount = self.tableView.numberOfRowsInSection(0)
//            
//            for var i = 0 ; i < addCount ;i += 1 {
//                actionArray.append(NSIndexPath(forRow: rowsCount + i, inSection: 0))
//            }
//            if actionArray.count > 0 {
//                self.tableView.insertRowsAtIndexPaths(actionArray, withRowAnimation: UITableViewRowAnimation.Fade)
//            }
//            
//            self.tableView.endUpdates()
//            
//            //self.tableView.reloadData()
//            //self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
//            self.scrollToEnd()
//        })
//    }
    
    func prepareAnnounceResponceWithTransactions(data: [TransactionPostMetaData]?) {
//        self.refreshHistory()
        if !(data ?? []).isEmpty {
            transactionMessageTextField!.text = ""
            transactionAmountTextField!.text = ""
            let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "TRANSACTION_ANOUNCE_SUCCESS".localized(), preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default) {
                alertAction -> Void in
            }
            
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: "TRANSACTION_ANOUNCE_FAILED".localized(), preferredStyle: UIAlertControllerStyle.Alert)
            
            let ok :UIAlertAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default) {
                alertAction -> Void in
            }
            
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private final func _getMinCosigFor(transaction: _MultisigTransaction) -> Int? {
        let innertTransaction =  (transaction.innerTransaction as! _TransferTransaction)
        let transactionsignerAddress = AddressGenerator.generateAddress(innertTransaction.signer)
        
        for account in _accounts {
            if account.address == transactionsignerAddress {
                return account.minCosignatories
            }
        }
        
        return nil
    }
    
    private func _failedWithError(text: String, completion :(Void -> Void)? = nil) {
        let alert :UIAlertController = UIAlertController(title: "INFO".localized(), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion?()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - View Controller Outlet Actions
    
    @IBAction func amoundFieldDidEndOnExit(sender: UITextField) {
        if Double(sender.text!) == nil {
            sender.text = "0"
        }
    }
    
    @IBAction func messageFieldDidEndOnExit(sender: UITextField) {

    }
    
    @IBAction func copyCorrespondentAddress(sender: AnyObject) {
        
        guard correspondent != nil else { return }
        
        let pasteBoard: UIPasteboard = UIPasteboard.generalPasteboard()
        pasteBoard.string = correspondent!.accountAddress
    }
    
    @IBAction func encTouchUpInside(sender: UIButton) {
        _isEnc = !_isEnc
        sender.backgroundColor = (_isEnc) ? greenColor : grayColor
    }
    
    @IBAction func accountsButtonDidTouchInside(sender: AnyObject){
        if _popup == nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let accounts :AccountChooserViewController =  storyboard.instantiateViewControllerWithIdentifier("AccountChooserViewController") as! AccountChooserViewController
            _popup = accounts
            accounts.view.frame = CGRect(x: tableView.frame.origin.x,
                                         y:  tableView.frame.origin.y,
                                         width: tableView.frame.width,
                                         height: tableView.frame.height)
            
            accounts.view.layer.opacity = 0
//            accounts.delegate = self
            
            var wallets = _mainAccount?.cosignatoryOf ?? []
            if _mainAccount != nil
            {
                wallets.append(self._mainAccount!)
            }
            accounts.wallets = wallets
            
            if accounts.wallets.count > 0
            {
                self.transactionSendButton.enabled = false
                self.view.addSubview(accounts.view)
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    accounts.view.layer.opacity = 1
                    }, completion: nil)
            }
        } else {
            _popup!.view.removeFromSuperview()
            _popup!.removeFromParentViewController()
            _popup = nil
        }
    }
    
    @IBAction func sendButtonTouchUpInside(sender: AnyObject) {
        
        if _activeAccount == nil || State.currentServer == nil {
            return
        }
        let amount = Double(transactionAmountTextField.text!) ?? 0
        if amount < 0.000001 && amount != 0 {
            transactionAmountTextField!.text = "0"
            return
        }
        
        let transaction :_TransferTransaction = _TransferTransaction()
        
        if let amount = Double(transactionAmountTextField!.text!) {
            if Double(_activeAccount?.balance ?? -1) > amount {
                transaction.amount = amount
            } else {
                _failedWithError("ACCOUNT_NOT_ENOUGHT_MONEY".localized())
                return
            }
        } else {
            transactionAmountTextField!.text = "0"
            transaction.amount = 0
            return
        }
                
        let messageTextHex = transactionMessageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)
        
        if !Validate.hexString(messageTextHex!) {
            _failedWithError("NOT_A_HEX_STRING".localized())
            return
        }
        
        var messageBytes :[UInt8] = messageTextHex!.asByteArray()
        
//        if _isEnc
//        {
//            guard let contactPublicKey = contact.public_key else {
//                _failedWithError("NO_PUBLIC_KEY_FOR_ENC".localized())
//
//                return
//            }
//            var encryptedMessage :[UInt8] = Array(count: 32, repeatedValue: 0)
//            encryptedMessage = MessageCrypto.encrypt(messageBytes, senderPrivateKey: HashManager.AES256Decrypt(State.currentWallet!.privateKey, key: State.loadData!.password!)!, recipientPublicKey: contactPublicKey)
//            messageBytes = encryptedMessage
//        }
        
        if messageBytes.count > 160 {
            _failedWithError("VALIDAATION_MESSAGE_LEANGTH".localized())
            return
        }
        
        transaction.message.payload = messageBytes
        transaction.message.type = (_isEnc) ? _MessageType.Ecrypted.rawValue : _MessageType.Normal.rawValue
        
        var fee = 0
        
        if transaction.amount >= 8 {
            fee = Int(max(2, 99 * atan(transaction.amount / 150000)))
        }
        else {
            fee = 10 - Int(transaction.amount)
        }
        var messageLength = transactionMessageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)?.asByteArray().count
        
        if _isEnc && messageLength != 0 {
            messageLength! += 64
        }

        if messageLength != 0 {
            fee += Int(2 * max(1, Int( messageLength! / 16)))
        }
        
        transaction.timeStamp = Double(Int(TimeSynchronizator.nemTime))
        transaction.fee = Double(fee)
//        transaction.recipient = contact.address
        transaction.type = transferTransaction
        transaction.deadline = Double(Int(TimeSynchronizator.nemTime + waitTime))
        transaction.version = 1
        transaction.signer = _activeAccount?.publicKey
        
//        _apiManager?.prepareAnnounce(State.currentServer!, transaction: transaction)
        
        self.view.endEditing(true)
    }
    
    //MARK: - DetailedTableViewCellDelegate Methods
    
    func showDetailsForCell(cell: DetailedTableViewCell) {
        cell.detailsIsShown = true
    }
    
    func hideDetailsForCell(cell: DetailedTableViewCell) {
        cell.detailsIsShown = false
    }
    
    //MARK: - AccountsChousePopUpDelegate Methods
    
    func didChouseAccount(account: AccountGetMetaData) {
        _activeAccount = account
        _popup?.view.removeFromSuperview()
        _popup?.removeFromParentViewController()
        _popup = nil
        
        self.transactionSendButton.enabled = true
        
        self.transactionEncryptionButton.enabled = _activeAccount?.address == account.address
        
        if _activeAccount?.address != account.address {
            _isEnc = false
            self.transactionEncryptionButton.backgroundColor = grayColor
        }
        
        let userDescription :NSMutableAttributedString = NSMutableAttributedString(string: "\(_activeAccount!.address.nemName())")
        
        let attribute = [NSForegroundColorAttributeName : UIColor(red: 65/256, green: 206/256, blue: 123/256, alpha: 1)]
        let balance = " \(self._activeAccount!.balance / 1000000) XEM"
        
        userDescription.appendAttributedString(NSMutableAttributedString(string: balance, attributes: attribute))
        
        dispatch_async(dispatch_get_main_queue() , {
            () -> Void in
            self.infoHeaderLabel.attributedText = userDescription
        })
    }
    
    private func _heightForCell(message: [Transaction], width: CGFloat) {
        
        for transaction in message {
            let transferTransaction = transaction as! TransferTransaction
            
            let message = transferTransaction.message?.message == String() || transferTransaction.message?.message == nil ? "EMPTY_MESSAGE".localized() : transferTransaction.message?.message
            let messageAttributedString = NSMutableAttributedString(string: message!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)])
            
            var amount = String()
            if (transferTransaction.amount > 0) {
                
                var symbol = String()
                if transferTransaction.transferType == .Incoming {
                    symbol = "+"
                } else {
                    symbol = "-"
                }
                
                amount = "\(symbol)\((transferTransaction.amount / 1000000).format()) XEM" ?? String()
                amount = "\n" + amount
                
                let amountAttributedString = NSMutableAttributedString(string: amount, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15, weight: UIFontWeightRegular)])
                messageAttributedString.appendAttributedString(amountAttributedString)
            }
            
            let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
            label.numberOfLines = 10
            label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            label.attributedText = messageAttributedString
            label.sizeToFit()
            
            rowHeight.append(label.frame.height + 50)
        }
    }
}

// MARK: - Table View Delegate

extension TransactionMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if unconfirmedTransactions.count > 0 {
            return transactions.count + unconfirmedTransactions.count + 1
        } else {
            return transactions.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == transactions.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("TransactionMessageGroupSeparatorTableViewCell")!
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TransactionMessageTableViewCell") as! TransactionMessageTableViewCell
//        cell.detailDelegate = self
//        cell.detailsIsShown = false
        
        if indexPath.row < transactions.count {
            let transaction = transactions[indexPath.row] as! TransferTransaction
            if transaction.transferType == .Incoming {
                cell.cellType = .Incoming
            } else {
                cell.cellType = .Outgoing
            }
            cell.transaction = transaction
            
        } else {
            let transaction = unconfirmedTransactions[indexPath.row - transactions.count - 1] as! TransferTransaction
            cell.cellType = .Processing
            cell.transaction = transaction
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == transactions.count {
            return 60.0
        }
        
        return rowHeight[indexPath.row]
    }
}
