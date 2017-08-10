//
//  WalletOverviewViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

/**
    The wallet overview gives the user an overview of his holdings.
    It lists all accounts and their corresponding balances and gives the user the ability to add new accounts to the wallet.
 */
final class WalletOverviewViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    /// All accounts that are stored on the device, which will get listed in the table view.
    fileprivate var accounts = [Account]()
    
    /// Fetched account data for all accounts, used to display account balances.
    fileprivate var accountData = [String: AccountData]()
    
    /// The number of owned assets for every account.
    fileprivate var accountAssets = [String: Int]()
    
    /// The latest market info, used to display fiat account balances.
    fileprivate var marketInfo: (xemPrice: Double, btcPrice: Double) = (0, 0)
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAccountButton: UIBarButtonItem!
    @IBOutlet weak var totalAccountBalanceLabel: UILabel!
    @IBOutlet weak var totalFiatBalanceLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadWalletOverview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateAccountDetails()
        fetchMarketInfo()
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showAccountDashboardViewController":
            
            if let indexPath = tableView.indexPathForSelectedRow {
                AccountManager.sharedInstance.activeAccount = accounts[indexPath.row]
            }
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads the wallet overview with the newest data.
    private func reloadWalletOverview() {
        
        fetchAccounts()
        updateBalanceSummary()
        createEditButtonItemIfNeeded()
        tableView.reloadData()
    }
    
    /// Updates the account details that are needed to show the balance and owned assets for every account.
    private func updateAccountDetails() {
        
        for account in accounts {
            fetchAccountBalance(forAccount: account)
            fetchOwnedAssets(forAccount: account)
        }
    }
    
    /// Fetches the latest market info, used to calculate the fiat balance for every account.
    private func fetchMarketInfo() {
        
        MarketInfoProvider.request(MarketInfo.xemPrice) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let xemPrice = json["BTC_XEM"]["highestBid"].doubleValue
                    
                    DispatchQueue.main.async {
                        
                        self?.marketInfo.xemPrice = xemPrice
                        self?.reloadWalletOverview()
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
        
        MarketInfoProvider.request(MarketInfo.btcPrice) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let btcPrice = json["USD"]["last"].doubleValue
                    
                    DispatchQueue.main.async {
                        
                        self?.marketInfo.btcPrice = btcPrice
                        self?.reloadWalletOverview()
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
        Updates the balance summary bar on top of the wallet overview with the current total 
        XEM and fiat balance for the wallet.
     */
    private func updateBalanceSummary() {
        
        var totalAccountBalance = 0.0
        var totalFiatBalance = 0.0
        
        for account in accounts {
            let accountBalance = accountData[account.address]?.balance ?? 0
            totalAccountBalance += accountBalance
            totalFiatBalance += (marketInfo.xemPrice * marketInfo.btcPrice * accountBalance)
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        totalAccountBalanceLabel.text = "\(totalAccountBalance.format()) XEM"
        totalFiatBalanceLabel.text = numberFormatter.string(from: totalFiatBalance as NSNumber)
    }
    
    /**
        Shows a confirmation alert for the account deletion and deletes the account if the user confirms the deletion,
        or cancels the action if not.
     
        - Parameter indexPath: The index path of the account in the accounts array, that should get deleted.
     */
    fileprivate func deleteAccount(atIndexPath indexPath: IndexPath) {
        
        let accountToDelete = accounts[indexPath.row]
        
        let accountDeletionAlert = UIAlertController(title: "INFO".localized(), message: String(format: "DELETE_CONFIRMATION_MASSAGE_ACCOUNTS".localized(), accountToDelete.title), preferredStyle: .alert)
        accountDeletionAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        accountDeletionAlert.addAction(UIAlertAction(title: "OK".localized(), style: .destructive, handler: { [unowned self] (action) in
            
            self.accounts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .bottom)
            self.createEditButtonItemIfNeeded()
            AccountManager.sharedInstance.delete(account: accountToDelete, completion: { _ in })
        }))
        
        present(accountDeletionAlert, animated: true, completion: nil)
    }
    
    /**
        Moves an account from its previous position in the array to the new position and saves that change in the database.
     
        - Parameter sourceIndexPath: The previous index path of the account in the accounts array (before the move).
        - Parameter destinationIndexPath: The new index path of the account in the accounts array (after the move)
     */
    fileprivate func moveAccount(fromPosition sourceIndexPath: IndexPath, toPosition destinationIndexPath: IndexPath) {
        
        if sourceIndexPath == destinationIndexPath { return }
        
        let accountToMove = accounts[sourceIndexPath.row]
        accounts.remove(at: sourceIndexPath.row)
        accounts.insert(accountToMove, at: destinationIndexPath.row)
        
        AccountManager.sharedInstance.updatePosition(ofAccounts: accounts, completion: { _ in })
    }
    
    /**
        Asks the user to change the title for an account and makes the change accordingly.
     
        - Parameter indexPath: The index path of the account in the accounts array for which the title should get updated.
     */
    fileprivate func changeTitle(forAccountAtIndexPath indexPath: IndexPath) {
        
        let account = accounts[indexPath.row]
        
        let accountTitleChangerAlert = UIAlertController(title: "CHANGE".localized(), message: "INPUT_NEW_ACCOUNT_NAME".localized(), preferredStyle: .alert)
        accountTitleChangerAlert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        accountTitleChangerAlert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { [unowned self] (action) in
            
            let titleTextField = accountTitleChangerAlert.textFields![0] as UITextField
            if let newTitle = titleTextField.text {
                
                self.accounts[indexPath.row].title = newTitle
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                AccountManager.sharedInstance.updateTitle(forAccount: self.accounts[indexPath.row], withNewTitle: newTitle)
            }
        }))
        
        accountTitleChangerAlert.addTextField { (textField) in
            textField.text = account.title
        }
        
        present(accountTitleChangerAlert, animated: true, completion: nil)
    }
    
    /// Fetches all accounts that are stored on the device.
    private func fetchAccounts() {
        accounts = AccountManager.sharedInstance.accounts()
    }
    
    /**
        Fetches the balance of the provided account.
     
        - Parameter account: The account, for which the balance should get fetched.
     */
    private func fetchAccountBalance(forAccount account: Account) {
        
        NEMProvider.request(NEM.accountData(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let accountData = try json.mapObject(AccountData.self)
                    
                    DispatchQueue.main.async {
                        
                        self?.accountData[account.address] = accountData
                        self?.reloadWalletOverview()
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
        Fetches the number of assets the provided account owns.
     
        - Parameter account: The account, for which the number of owned assets should get fetched.
     */
    private func fetchOwnedAssets(forAccount account: Account) {
        
        NEMProvider.request(NEM.ownedMosaics(accountAddress: account.address)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    let ownedMosaics = json["data"].count - 1
                    
                    DispatchQueue.main.async {
                        
                        self?.accountAssets[account.address] = ownedMosaics
                        self?.reloadWalletOverview()
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
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    /**
        Checks if there are any accounts to show and creates an edit button item on the right of the
        navigation bar if that's the case.
     */
    private func createEditButtonItemIfNeeded() {
                
        if (accounts.count > 0) {
            navigationItem.setRightBarButtonItems([addAccountButton, editButtonItem], animated: true)
        } else {
            navigationItem.setRightBarButtonItems([addAccountButton], animated: true)
        }
    }
    
    // MARK: - View Controller Outlet Actions
    
    /// Unwinds to the wallet overview view controller and reloads the wallet overview.
    @IBAction func unwindToWalletOverviewViewController(_ segue: UIStoryboardSegue) {
        reloadWalletOverview()
        updateAccountDetails()
    }
}

extension WalletOverviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let account = accounts[indexPath.row]
        let accountBalance = accountData[account.address]?.balance ?? 0
        let accountAssets = self.accountAssets[account.address] ?? 0
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        let accountTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") as! AccountTableViewCell
        accountTableViewCell.accountTitleLabel.text = account.title
        accountTableViewCell.accountBalanceLabel.text = "\(accountBalance.format()) XEM"
        accountTableViewCell.accountFiatBalanceLabel.text = numberFormatter.string(from: (marketInfo.xemPrice * marketInfo.btcPrice * accountBalance) as NSNumber)
        
        if accountAssets != 0 {
            accountTableViewCell.accountAssetsLabel.text = accountAssets == 1 ? "\(accountAssets) other asset" : "\(accountAssets) other assets"
            accountTableViewCell.showAccountAssetsSummary()
        } else {
            accountTableViewCell.accountAssetsLabel.text = "\(accountAssets) other assets"
            accountTableViewCell.hideAccountAssetsSummary()
        }
        
        return accountTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            changeTitle(forAccountAtIndexPath: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            performSegue(withIdentifier: "showAccountDashboardViewController", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            deleteAccount(atIndexPath: indexPath)
            
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveAccount(fromPosition: sourceIndexPath, toPosition: destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
