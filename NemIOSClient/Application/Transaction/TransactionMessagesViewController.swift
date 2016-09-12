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
class TransactionMessagesViewController: UIViewController, UIAlertViewDelegate {
    
    // MARK: - View Controller Properties
    
    var account: Account?
    var correspondent: Correspondent?
    var accountData: AccountData?
    private var activeAccountData: AccountData?
    private var transactions = [Transaction]()
    private var unconfirmedTransactions = [Transaction]()
    private var rowHeight = [CGFloat]()
    private var willEncrypt = false
    private var accountChooserViewController: UIViewController?
    
    private var refreshTimer: NSTimer? = nil
    private let correspondentTransactionsDispatchGroup = GCDGroup()

    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoHeaderLabel: UILabel!
    @IBOutlet weak var transactionAmountTextField: UITextField!
    @IBOutlet weak var transactionMessageTextField: UITextField!
    @IBOutlet weak var transactionEncryptionButton: UIButton!
    @IBOutlet weak var transactionSendButton: UIButton!
    @IBOutlet weak var transactionAccountChooserButton: UIButton!
    @IBOutlet weak var transactionAmountContainerView: UIView!
    @IBOutlet weak var transactionEncryptionButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionSendBarView: UIView!
    @IBOutlet weak var transactionSendBarBorderView: UIView!

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
        if accountData != nil {
            updateInfoHeaderLabel(withAccountData: accountData)
        }
        
        updateViewControllerAppearance()
        createBarButtonItem()
        showCorrespondentTransactions()
        startRefreshing()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TransactionMessagesViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
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
        transactionAmountTextField.placeholder = "AMOUNT".localized()
        transactionMessageTextField.placeholder = "MESSAGE".localized()
        transactionSendButton.setTitle("SEND".localized(), forState: UIControlState.Normal)
        transactionAccountChooserButton.setTitle("ACCOUNTS".localized(), forState: UIControlState.Normal)
        
        transactionAccountChooserButton.layer.cornerRadius = 5
        transactionSendButton.layer.cornerRadius = 5
        transactionAmountContainerView.layer.cornerRadius = 5
        transactionAmountContainerView.clipsToBounds = true
        transactionMessageTextField.layer.cornerRadius = 5
        
        if accountData!.cosignatories?.count > 0 {
            transactionSendBarView.hidden = true
            transactionSendBarBorderView.hidden = true
        }
        
        if accountData!.cosignatoryOf?.count > 0 {
            transactionAccountChooserButton.hidden = false
            transactionEncryptionButtonTrailingConstraint.constant = -(transactionAccountChooserButton.frame.width + 5)
        }
    }
    
    /// Creates and adds the compose bar button item to the view controller.
    private func createBarButtonItem() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(copyCorrespondentAddress(_:)))
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
        
        let accountTitle = accountData!.title != nil ? accountData!.title! : accountData!.address.nemAddressNormalised()
        let infoHeaderText = NSMutableAttributedString(string: "\(accountTitle) ·")
        let infoHeaderTextBalance = " \((accountData!.balance / 1000000).format()) XEM"
        infoHeaderText.appendAttributedString(NSMutableAttributedString(string: infoHeaderTextBalance, attributes: [NSForegroundColorAttributeName: UIColor(red: 90.0/255.0, green: 179.0/255.0, blue: 232.0/255.0, alpha: 1), NSFontAttributeName: UIFont.systemFontOfSize(infoHeaderLabel.font.pointSize, weight: UIFontWeightRegular)]))
        
        infoHeaderLabel.attributedText = infoHeaderText
    }
    
    /// Scrolls to the table view bottom as soon as the keyboard appears.
    func keyboardWillShowNotification(notification: NSNotification) {
        scrollToTableBottom(true)
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
        Updates the correspondent transactions table view with the provided
        transactions from the correspondent. Shows the already fetched transactions
        instantly upon view did load. Use this function only on view did load.
     */
    func showCorrespondentTransactions() {
        
        transactions = correspondent!.transactions
        unconfirmedTransactions = correspondent!.unconfirmedTransactions
        
        getTransactionsForCorrespondent(fromTransactions: &self.transactions)
        getTransactionsForCorrespondent(fromTransactions: &self.unconfirmedTransactions)
        
        calculateCellHeights()
        
        tableView.reloadData()
        scrollToTableBottom()
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
            
            self.rowHeight = [CGFloat]()
            self.calculateCellHeights()
            
            self.tableView.reloadData()
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
                    
                    let json = JSON(data: response.data)
                    let accountData = try json.mapObject(AccountData)
                    
                    GCDQueue.Main.async {
                        
                        if self?.activeAccountData?.address == self?.account?.address {
                            self?.updateInfoHeaderLabel(withAccountData: accountData)
                        }
                        
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
        Signs and announces a new transaction to the NIS.
     
        - Parameter transaction: The transaction object that should get signed and announced.
     */
    private func announceTransaction(transaction: Transaction) {
        
        let requestAnnounce = TransactionManager.sharedInstance.signTransaction(transaction, account: account!)
        
        nisProvider.request(NIS.AnnounceTransaction(requestAnnounce: requestAnnounce)) { [weak self] (result) in
            
            switch result {
            case let .Success(response):
                
                do {
                    try response.filterSuccessfulStatusCodes()
                    let responseJSON = JSON(data: response.data)
                    try self?.validateAnnounceTransactionResult(responseJSON)
                    
                    GCDQueue.Main.async {
                        
                        self?.showAlert(withMessage: "TRANSACTION_ANOUNCE_SUCCESS".localized())
                        
                        if self != nil && transaction.type == .TransferTransaction {
                            self!.unconfirmedTransactions.append(transaction)
                            self!.getCellHeights(forTransactions: [transaction], withViewWidth: self!.tableView.frame.width - 120)
                            self!.tableView.reloadData()
                            self!.scrollToTableBottom(false)
                        }
                    }
                    
                } catch TransactionAnnounceValidation.Failure(let errorMessage) {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")
                        self?.showAlert(withMessage: errorMessage)
                    }
                    
                } catch {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")
                        self?.showAlert(withMessage: "TRANSACTION_ANOUNCE_FAILED".localized())
                    }
                }
                
            case let .Failure(error):
                
                GCDQueue.Main.async {
                    
                    print(error)
                    self?.updateInfoHeaderLabel(withAccountData: nil)
                    self?.showAlert(withMessage: "TRANSACTION_ANOUNCE_FAILED".localized())
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
                    
                    if AccountManager.sharedInstance.generateAddress(forPublicKey: transaction.signer) == correspondent?.accountAddress && transaction.recipient == account!.address {
                        transaction.transferType = .Incoming
                        correspondentTransactions.append(transaction)
                    } else if transaction.recipient == correspondent?.accountAddress && transaction.signer == account!.publicKey {
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
    
    /**
        Validates the response (announce transaction result object) of the NIS
        regarding the announcement of the transaction.
     
        - Parameter responseJSON: The response of the NIS JSON formatted.
     
        - Throws:
            - TransactionAnnounceValidation.Failure if the announcement of the transaction wasn't successful.
     */
    private func validateAnnounceTransactionResult(responseJSON: JSON) throws {
        
        guard let responseCode = responseJSON["code"].int else { throw TransactionAnnounceValidation.Failure(errorMessage: "TRANSACTION_ANOUNCE_FAILED".localized()) }
        let responseMessage = responseJSON["message"].stringValue
        
        switch responseCode {
        case 1:
            return
        default:
            throw TransactionAnnounceValidation.Failure(errorMessage: responseMessage)
        }
    }
    
    /// Calculates the heights for all transaction table view cells.
    private func calculateCellHeights() {
        
        getCellHeights(forTransactions: transactions, withViewWidth: tableView.frame.width - 120)
        rowHeight.append(CGFloat())
        getCellHeights(forTransactions: unconfirmedTransactions, withViewWidth: tableView.frame.width - 120)
    }
    
    /**
        Calculates the height for all table view cells. The calculated heights get stored
        in the array rowHeight and will get applied to the cells.
     
        - Parameter transactions: The transactions for which the cell heights should get calculated.
        - Parameter width: The width of the table view.
     */
    private func getCellHeights(forTransactions transactions: [Transaction], withViewWidth width: CGFloat) {
        
        for transaction in transactions {
            
            let transferTransaction = transaction as! TransferTransaction
            
            var message = transferTransaction.message?.message == String() || transferTransaction.message?.message == nil ? "" : transferTransaction.message?.message
            var amount = String()
            
            if (transferTransaction.amount > 0) {
                
                var symbol = String()
                if transferTransaction.transferType == .Incoming {
                    symbol = "+"
                } else {
                    symbol = "-"
                }
                
                amount = "\(symbol)\((transferTransaction.amount / 1000000).format()) XEM" ?? String()
                
                if message != "" {
                    amount = "\n" + amount
                }
                
            } else {
                
                if message == "" {
                    message = "EMPTY_MESSAGE".localized()
                }
            }
            
            let messageAttributedString = NSMutableAttributedString(string: message!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(13, weight: UIFontWeightRegular)])
            let amountAttributedString = NSMutableAttributedString(string: amount, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15, weight: UIFontWeightRegular)])
            messageAttributedString.appendAttributedString(amountAttributedString)
            
            let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
            label.numberOfLines = 10
            label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            label.attributedText = messageAttributedString
            label.sizeToFit()
            
            rowHeight.append(label.frame.height + 50)
        }
    }
    
    /**
        Scrolls to the bottom of the table view.
     
        - Parameter animated: Bool whether the scrolling should get animated or not.
     */
    private func scrollToTableBottom(animated: Bool = false) {
        
        if tableView.contentSize.height > tableView.frame.size.height {
            let offset = CGPointMake(0, tableView.contentSize.height - tableView.frame.size.height)
            tableView.setContentOffset(offset, animated: animated)
        }
    }
    
    /// Copies the correspondent address to the pasteboard.
    func copyCorrespondentAddress(sender: AnyObject) {
        
        guard correspondent != nil else { return }
        
        let pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = correspondent!.accountAddress
    }
    
    /**
        Shows an alert view controller with the provided alert message.
     
        - Parameter message: The message that should get shown.
        - Parameter completion: An optional action that should get performed on completion.
     */
    private func showAlert(withMessage message: String, completion: (Void -> Void)? = nil) {
        
        let alert = UIAlertController(title: "INFO".localized(), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion?()
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - View Controller Outlet Actions
    
    @IBAction func toggleEncryptionSetting(sender: UIButton) {
        
        willEncrypt = !willEncrypt
        sender.backgroundColor = (willEncrypt) ? UIColor(red: 90.0/255.0, green: 179.0/255.0, blue: 232.0/255.0, alpha: 1) : UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    @IBAction func amountTextFieldDidEndOnExit(sender: UITextField) {
        
        if Double(sender.text!) == nil {
            sender.text = "0"
        }
    }
    
    @IBAction func chooseAccount(sender: UIButton) {
        
        if accountChooserViewController == nil {
            
            var accounts = accountData!.cosignatoryOf ?? []
            accounts.append(accountData!)
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let accountChooserViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AccountChooserViewController") as! AccountChooserViewController
            accountChooserViewController.view.frame = CGRect(x: tableView.frame.origin.x, y:  tableView.frame.origin.y, width: tableView.frame.width, height: tableView.frame.height)
            accountChooserViewController.view.layer.opacity = 0
            accountChooserViewController.delegate = self
            accountChooserViewController.accounts = accounts

            self.accountChooserViewController = accountChooserViewController

            if accounts.count > 0 {
                transactionSendButton.enabled = false
                view.addSubview(accountChooserViewController.view)
                
                UIView.animateWithDuration(0.2, animations: {
                    accountChooserViewController.view.layer.opacity = 1
                })
            }
            
        } else {
            
            accountChooserViewController!.view.removeFromSuperview()
            accountChooserViewController!.removeFromParentViewController()
            accountChooserViewController = nil
        }
    }
    
    @IBAction func createTransaction(sender: AnyObject) {
        
        guard transactionAmountTextField.text != nil else { return }
        guard transactionMessageTextField.text != nil else { return }
        if activeAccountData == nil { activeAccountData = accountData }
        
        let transactionVersion = 1
        let transactionTimeStamp = Int(TimeManager.sharedInstance.timeStamp)
        let transactionAmount = Double(transactionAmountTextField.text!) ?? 0.0
        var transactionFee = 0.0
        let transactionRecipient = correspondent!.accountAddress
        let transactionMessageText = transactionMessageTextField.text!.hexadecimalStringUsingEncoding(NSUTF8StringEncoding) ?? String()
        var transactionMessageByteArray: [UInt8] = transactionMessageText.asByteArray()
        let transactionDeadline = Int(TimeManager.sharedInstance.timeStamp + waitTime)
        let transactionSigner = activeAccountData!.publicKey
        
        if transactionAmount < 0.000001 && transactionAmount != 0 {
            transactionAmountTextField!.text = "0"
            return
        }
        guard (activeAccountData!.balance / 1000000) > transactionAmount else {
            showAlert(withMessage: "ACCOUNT_NOT_ENOUGHT_MONEY".localized())
            return
        }
        guard TransactionManager.sharedInstance.validateHexadecimalString(transactionMessageText) == true else {
            showAlert(withMessage: "NOT_A_HEX_STRING".localized())
            return
        }
        
        if willEncrypt {
            guard let recipientPublicKey = correspondent?.accountPublicKey else {
                showAlert(withMessage: "NO_PUBLIC_KEY_FOR_ENC".localized())
                return
            }
            
            var transactionEncryptedMessageByteArray: [UInt8] = Array(count: 32, repeatedValue: 0)
            transactionEncryptedMessageByteArray = TransactionManager.sharedInstance.encryptMessage(transactionMessageByteArray, senderEncryptedPrivateKey: account!.privateKey, recipientPublicKey: recipientPublicKey)
            transactionMessageByteArray = transactionEncryptedMessageByteArray
        }
        
        if transactionMessageByteArray.count > 160 {
            showAlert(withMessage: "VALIDAATION_MESSAGE_LEANGTH".localized())
            return
        }
        
        transactionFee = TransactionManager.sharedInstance.calculateFee(forTransactionWithAmount: transactionAmount)
        transactionFee += TransactionManager.sharedInstance.calculateFee(forTransactionWithMessage: transactionMessageByteArray)
        
        let transactionMessage = Message(type: willEncrypt ? MessageType.Encrypted : MessageType.Unencrypted, payload: transactionMessageByteArray, message: transactionMessageTextField.text!)
        let transaction = TransferTransaction(version: transactionVersion, timeStamp: transactionTimeStamp, amount: transactionAmount * 1000000, fee: Int(transactionFee * 1000000), recipient: transactionRecipient, message: transactionMessage, deadline: transactionDeadline, signer: transactionSigner)
        
        // Check if the transaction is a multisig transaction
        if activeAccountData!.publicKey != account!.publicKey {
            
            let multisigTransaction = MultisigTransaction(version: transactionVersion, timeStamp: transactionTimeStamp, fee: Int(6 * 1000000), deadline: transactionDeadline, signer: account!.publicKey, innerTransaction: transaction!)
            
            announceTransaction(multisigTransaction!)
            return
        }
        
        announceTransaction(transaction!)
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

// MARK: - Account Chooser Delegate

extension TransactionMessagesViewController: AccountChooserDelegate {
    
    func didChooseAccount(accountData: AccountData) {
        
        activeAccountData = accountData
        
        accountChooserViewController?.view.removeFromSuperview()
        accountChooserViewController?.removeFromParentViewController()
        accountChooserViewController = nil
        
        transactionSendButton.enabled = true
        transactionEncryptionButton.enabled = activeAccountData?.address == self.accountData?.address
        
        if activeAccountData?.address != self.accountData?.address {
            willEncrypt = false
            transactionEncryptionButton.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
        }
        
        updateInfoHeaderLabel(withAccountData: activeAccountData)
    }
}
