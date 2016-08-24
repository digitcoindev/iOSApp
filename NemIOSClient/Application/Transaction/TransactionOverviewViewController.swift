//
//  TransactionOverviewViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import GCDKit
import SwiftyJSON

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
    
    private var refreshTimer: NSTimer? = nil
    private let transactionOverviewDispatchGroup = GCDGroup()
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoHeaderLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = getAccount()
        
        guard account != nil else {
            print("Critical: Account not available!")
            return
        }
        
        showLoadingView()
        updateViewControllerAppearanceOnViewDidLoad()
        refreshTransactionOverview()
        startRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewControllerAppearanceOnViewWillAppear()
        createBarButtonItem()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "showTransactionNormalMessagesViewController":
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destinationViewController as! TransactionMessagesViewController
                destinationViewController.account = account
                destinationViewController.correspondent = correspondents[indexPath.row]
            }
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller on view did load.
    private func updateViewControllerAppearanceOnViewDidLoad() {
        
        tabBarController?.title = "MESSAGES".localized()
        infoHeaderLabel.text = "NO_INTERNET_CONNECTION".localized()
    }
    
    /// Updates the appearance (coloring, titles) of the view controller on view will appear.
    private func updateViewControllerAppearanceOnViewWillAppear() {
        
        tabBarController?.title = "MESSAGES".localized()
    }
    
    /// Creates and adds the compose bar button item to the view controller.
    private func createBarButtonItem() {
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(segueToTransactionSendViewController))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        rightBarButtonItem.enabled = false
        
        tabBarController?.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    /// Segues to the transaction send view controller.
    func segueToTransactionSendViewController() {
        performSegueWithIdentifier("showTransactionSendViewController", sender: nil)
    }
    
    /**
        Fetches the account for which the transaction overview should get
        shown from the parent account detail tab bar controller.
     
        - Returns: The account for which the transaction overview should get shown.
     */
    private func getAccount() -> Account? {
        
        var account: Account?
        
        if let accountDetailTabBarController = tabBarController as? AccountDetailTabBarController {
            guard accountDetailTabBarController.account != nil else {
                return account
            }
            
            account = accountDetailTabBarController.account!
        }
            
        return account
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
        
        let infoHeaderText = NSMutableAttributedString(string: "\(self.account!.title) ·")
        let infoHeaderTextBalance = " \((accountData!.balance / 1000000).format()) XEM"
        infoHeaderText.appendAttributedString(NSMutableAttributedString(string: infoHeaderTextBalance, attributes: [NSForegroundColorAttributeName: UIColor(red: 90.0/255.0, green: 179.0/255.0, blue: 232.0/255.0, alpha: 1), NSFontAttributeName: UIFont.systemFontOfSize(infoHeaderLabel.font.pointSize, weight: UIFontWeightRegular)]))
        
        infoHeaderLabel.attributedText = infoHeaderText
    }
    
    /**
        Shows the loading view above the table view which shows
        an spinning activity indicator.
     */
    private func showLoadingView() {
        
        loadingActivityIndicator.startAnimating()
        loadingView.hidden = false
    }
    
    /// Hides the loading view.
    private func hideLoadingView() {
        
        loadingView.hidden = true
        loadingActivityIndicator.stopAnimating()
    }
    
    /// Starts refreshing the transaction overview in the defined interval.
    private func startRefreshing() {
        
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(updateInterval), target: self, selector: #selector(TransactionOverviewViewController.refreshTransactionOverview), userInfo: nil, repeats: true)
    }
    
    /// Stops refreshing the transaction overview.
    private func stopRefreshing() {
        refreshTimer?.invalidate()
    }
    
    /**
        Updates the transaction overview table view in an asynchronous manner.
        Fires off all necessary network calls to get the information needed.
        Use only this method to update the displayed information.
    */
    func refreshTransactionOverview() {
        
        transactions = [Transaction]()
        
        fetchAccountData(forAccount: account!)
        fetchAllTransactions(forAccount: account!)
        fetchUnconfirmedTransactions(forAccount: account!)
        
        transactionOverviewDispatchGroup.notify(.Main) {
            self.transactions.sortInPlace({ $0.timeStamp < $1.timeStamp })
            self.getCorrespondents(forTransactions: self.transactions)
        }
    }
    
    /**
        Fetches the account data (balance, cosignatories, etc.) for the current account from the active NIS.
        After a successful fetch the info header label gets updated with the account balance. The function
        also checks if the account is a multisig account and disables the compose bar button item accordingly.
        Do not call this function directly. Use the method refreshTransactionOverview.
     
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
        Do not call this function directly. Use the method refreshTransactionOverview.
     
        - Parameter account: The current account for which the transactions should get fetched.
     */
    private func fetchAllTransactions(forAccount account: Account) {
        
        transactionOverviewDispatchGroup.enter()
        
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

                        self?.transactions += allTransactions

                        self?.transactionOverviewDispatchGroup.leave()
                    }
                    
                } catch {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")

                        self?.transactionOverviewDispatchGroup.leave()
                    }
                }
                
            case let .Failure(error):
                
                GCDQueue.Main.async {
                    
                    print(error)
                    self?.updateInfoHeaderLabel(withAccountData: nil)
                    
                    self?.transactionOverviewDispatchGroup.leave()
                }
            }
        }
    }
    
    /**
        Fetches all unconfirmed transactions for the provided account.
        Do not call this function directly. Use the method refreshTransactionOverview.
     
        - Parameter account: The account for which all unconfirmed transaction should get fetched.
     */
    private func fetchUnconfirmedTransactions(forAccount account: Account) {
        
        transactionOverviewDispatchGroup.enter()
        
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
                        
                        self?.transactions += unconfirmedTransactions

                        self?.transactionOverviewDispatchGroup.leave()
                    }
                    
                } catch {
                    
                    GCDQueue.Main.async {
                        
                        print("Failure: \(response.statusCode)")
                        
                        self?.transactionOverviewDispatchGroup.leave()
                    }
                }
                
            case let .Failure(error):
                
                GCDQueue.Main.async {
                    
                    print(error)
                    self?.updateInfoHeaderLabel(withAccountData: nil)
                    
                    self?.transactionOverviewDispatchGroup.leave()
                }
            }
        }
    }
    
    /**
        Determines all correspondents for the provided transactions. Updates the table view with the
        correspondents once finished. Do not call this function directly. Use the method refreshTransactionOverview.
     
        - Parameter transactions: The transactions for which the correspondents should get determined.
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
                    transaction.transferType = .Outgoing
                } else {
                    correspondent.accountAddress = AccountManager.sharedInstance.generateAddress(forPublicKey: transaction.signer)
                    transaction.transferType = .Incoming
                }
                
                if correspondents.contains(correspondent) {
                    if let index = correspondents.indexOf(correspondent) {
                        correspondents[index].transactions.append(transaction)
                        correspondents[index].mostRecentTransaction = transaction
                    }
                } else {
                    correspondent.transactions.append(transaction)
                    correspondent.mostRecentTransaction = transaction
                    correspondents.append(correspondent)
                }
                
            default:
                break
            }
        }
        
        correspondents.sortInPlace({ $0.mostRecentTransaction.timeStamp > $1.mostRecentTransaction.timeStamp })
        searchNames(forCorrespondents: &correspondents)

        self.correspondents = correspondents
        
        tableView.reloadData()
        hideLoadingView()
    }
    
    /**
        Searches the names for the provided correspondents if available. Checks if the
        correspondent is an account on the device and otherwise searches in the address
        book for a matching address. If the name for a correspondent couldn't be found,
        the account address of the correspondent will get shown in the transaction overview.
     
        - Parameter correspondents: The correspondents for which the names should get searched. This is a inout parameter and will write the names directly to the provided correspondent array.
     */
    private func searchNames(inout forCorrespondents correspondents: [Correspondent]) {
        
        let accounts = AccountManager.sharedInstance.accounts()
        
        for correspondent in correspondents {
            for account in accounts where account.address == correspondent.accountAddress {
                correspondent.name = account.title
            }
        }
    }
}

// MARK: - Table View Data Source

extension TransactionOverviewViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return correspondents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TransactionOverviewCorrespondentTableViewCell") as! TransactionOverviewCorrespondentTableViewCell
        cell.account = account
        cell.correspondent = correspondents[indexPath.row]
        
        return cell
    }
}

// MARK: - Table View Delegate

extension TransactionOverviewViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
        if accountData!.cosignatories.count > 0 {
            performSegueWithIdentifier("showTransactionMultisignatureMessagesViewController", sender: nil)
        } else if accountData!.cosignatoryOf.count > 0 {
            performSegueWithIdentifier("showTransactionCosignatoryMessagesViewController", sender: nil)
        } else {
            performSegueWithIdentifier("showTransactionNormalMessagesViewController", sender: nil)
        }
    }
}
