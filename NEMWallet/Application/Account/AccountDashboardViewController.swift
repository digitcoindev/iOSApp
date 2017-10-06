//
//  AccountDashboardViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

/**
     The account dashboard gives the user an overview of an account.
     It shows all confirmed as well as unconfirmed transactions.
 */
final class AccountDashboardViewController: UITableViewController {
    
    // MARK: - View Controller Properties

    ///
    fileprivate var unconfirmedTransactions = [Transaction]()
    
    ///
    fileprivate var confirmedTransactionsBySection = [String: [Transaction]]()
    
    ///
    fileprivate var transactionSections = [String]()
    
    ///
    public var accountBalance = Double()
    
    ///
    public var accountFiatBalance = Double()
    
    ///
    public var accountAssets = Int()
    
    ///
    public var accountData: AccountData?
    
    ///
    fileprivate var account: Account?
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountManager.sharedInstance.activeAccount
        
        tableView.estimatedRowHeight = 110.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        fetchConfirmedTransactions()
        fetchUnconfirmedTransactions()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showAccountDetailsViewController":
            
            let destinationViewController = segue.destination as! AccountDetailsViewController
            destinationViewController.account = account
            destinationViewController.accountBalance = accountBalance
            destinationViewController.accountFiatBalance = accountFiatBalance
            destinationViewController.accountData = accountData
            
        case "showTransactionDetailsViewController":
            
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                
                var transaction: Transaction!
                if unconfirmedTransactions.count > 0 && indexPathForSelectedRow.section == 1 {
                    transaction = unconfirmedTransactions[indexPathForSelectedRow.row]
                } else {
                    let section = transactionSections[unconfirmedTransactions.count > 0 ? indexPathForSelectedRow.section - 2 : indexPathForSelectedRow.section - 1]
                    transaction = confirmedTransactionsBySection[section]![indexPathForSelectedRow.row]
                }
                
                let destinationViewController = segue.destination as! TransactionDetailsViewController
                destinationViewController.account = account
                destinationViewController.accountBalance = accountBalance
                destinationViewController.accountFiatBalance = accountFiatBalance
                destinationViewController.transaction = transaction
            }
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads the account dashboard with the newest data.
    private func reloadAccountDashboard() {
        tableView.reloadData()
    }
    
    /// Fetches the last 25 transactions for the current account.
    private func fetchConfirmedTransactions() {
        
        NEMProvider.request(NEM.confirmedTransactions(accountAddress: account!.address, server: nil)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var transactionSections = [String]()
                    var confirmedTransactionsBySection = [String: [Transaction]]()
                    
                    for (_, subJson) in json["data"] {
                        
                        switch subJson["transaction"]["type"].intValue {
                        case TransactionType.transferTransaction.rawValue:
                            
                            let transferTransaction = try subJson.mapObject(TransferTransaction.self)
                            let sectionTitle = transferTransaction.timeStamp.sectionTitle()
                            
                            if confirmedTransactionsBySection[sectionTitle] == nil {
                                confirmedTransactionsBySection[sectionTitle] = [Transaction]()
                                transactionSections.append(sectionTitle)
                            }
                            
                            confirmedTransactionsBySection[sectionTitle]?.append(transferTransaction)
                            
                        case TransactionType.multisigTransaction.rawValue:
                            
                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
                            case TransactionType.transferTransaction.rawValue:
                                
                                let multisigTransaction = try subJson.mapObject(MultisigTransaction.self)
                                let sectionTitle = multisigTransaction.timeStamp.sectionTitle()
                                
                                if confirmedTransactionsBySection[sectionTitle] == nil {
                                    confirmedTransactionsBySection[sectionTitle] = [Transaction]()
                                    transactionSections.append(sectionTitle)
                                }
                                
                                confirmedTransactionsBySection[sectionTitle]?.append(multisigTransaction)
                                
                            default:
                                break
                            }
                            
                        default:
                            break
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self?.transactionSections = transactionSections
                        self?.confirmedTransactionsBySection = confirmedTransactionsBySection
                        self?.reloadAccountDashboard()
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
    
    /// Fetches all unconfirmed transactions for the account.
    private func fetchUnconfirmedTransactions() {
        
        NEMProvider.request(NEM.unconfirmedTransactions(accountAddress: account!.address, server: nil)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var unconfirmedTransactions = [Transaction]()
                    
                    for (_, subJson) in json["data"] {
                        
                        switch subJson["transaction"]["type"].intValue {
                        case TransactionType.transferTransaction.rawValue:
                            
                            let transferTransaction = try subJson.mapObject(TransferTransaction.self)
                            unconfirmedTransactions.append(transferTransaction)
                            
                        case TransactionType.multisigTransaction.rawValue:
                            
                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
                            case TransactionType.transferTransaction.rawValue:
                                
                                let multisigTransaction = try subJson.mapObject(MultisigTransaction.self)
                                unconfirmedTransactions.append(multisigTransaction)
                                
                            default:
                                break
                            }
                            
                        default:
                            break
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self?.unconfirmedTransactions = unconfirmedTransactions
                        self?.reloadAccountDashboard()
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
}

extension AccountDashboardViewController {
    
    // MARK: - Table View Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if unconfirmedTransactions.count > 0 {
            return transactionSections.count + 2
        } else {
            return transactionSections.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if accountAssets != 0 {
                return 2
            } else {
                return 1
            }
        } else if unconfirmedTransactions.count > 0 && section == 1 {
            return unconfirmedTransactions.count
        } else {
            return confirmedTransactionsBySection[transactionSections[unconfirmedTransactions.count > 0 ? section - 2 : section - 1]]?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                let accountSummaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountSummaryTableViewCell") as! AccountSummaryTableViewCell
                accountSummaryTableViewCell.accountTitleLabel.text = account?.title ?? ""
                accountSummaryTableViewCell.accountBalanceLabel.text = "\(accountBalance.format()) XEM"
                accountSummaryTableViewCell.accountFiatBalanceLabel.text = numberFormatter.string(from: accountFiatBalance as NSNumber)
                
                return accountSummaryTableViewCell
                
            } else {
                
                let accountAssetsSummaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountAssetsSummaryTableViewCell") as! AccountAssetsSummaryTableViewCell
                accountAssetsSummaryTableViewCell.assetsLabel.text = "\(accountAssets) other assets"
                accountAssetsSummaryTableViewCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                
                return accountAssetsSummaryTableViewCell
            }
            
        } else {
            
            let transaction: Transaction!
            if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                transaction = unconfirmedTransactions[indexPath.row]
            } else {
                let section = transactionSections[unconfirmedTransactions.count > 0 ? indexPath.section - 2 : indexPath.section - 1]
                transaction = confirmedTransactionsBySection[section]![indexPath.row]
            }
            
            switch transaction.type {
            case TransactionType.transferTransaction:
                
                let transferTransaction = transaction as! TransferTransaction
                
                let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                transactionTableViewCell.transactionMessageLabel.text = transferTransaction.message?.message ?? ""
                transactionTableViewCell.transactionDateLabel.text = transferTransaction.timeStamp.format()
                
                if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                    transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                } else {
                    transactionTableViewCell.backgroundColor = UIColor.white
                }
                
                if transferTransaction.transferType == .incoming {
                    transactionTableViewCell.transactionCorrespondentLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer).nemAddressNormalised()
                    transactionTableViewCell.transactionAmountLabel.text = "+\(transferTransaction.amount.format()) XEM"
                    transactionTableViewCell.transactionAmountLabel.textColor = Constants.incomingColor
                } else if transferTransaction.transferType == .outgoing {
                    transactionTableViewCell.transactionCorrespondentLabel.text = transferTransaction.recipient.nemAddressNormalised()
                    transactionTableViewCell.transactionAmountLabel.text = "-\(transferTransaction.amount.format()) XEM"
                    transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                }
                
                return transactionTableViewCell
                
            case TransactionType.multisigTransaction:
                
                let multisigTransaction = transaction as! MultisigTransaction
                
                switch multisigTransaction.innerTransaction.type {
                case TransactionType.transferTransaction:

                    let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction

                    let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                    transactionTableViewCell.transactionMessageLabel.text = transferTransaction.message?.message ?? ""
                    transactionTableViewCell.transactionDateLabel.text = transferTransaction.timeStamp.format()
                    
                    if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                        transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                    } else {
                        transactionTableViewCell.backgroundColor = UIColor.white
                    }
                    
                    if transferTransaction.transferType == .incoming {
                        transactionTableViewCell.transactionCorrespondentLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer).nemAddressNormalised()
                        transactionTableViewCell.transactionAmountLabel.text = "+\(transferTransaction.amount.format()) XEM"
                        transactionTableViewCell.transactionAmountLabel.textColor = Constants.incomingColor
                    } else if transferTransaction.transferType == .outgoing {
                        transactionTableViewCell.transactionCorrespondentLabel.text = transferTransaction.recipient.nemAddressNormalised()
                        transactionTableViewCell.transactionAmountLabel.text = "-\(transferTransaction.amount.format()) XEM"
                        transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                    }
                    
                    return transactionTableViewCell
                    
                default:
                    return UITableViewCell()
                }
                
            default:
                return UITableViewCell()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return ""
        } else if unconfirmedTransactions.count > 0 && section == 1 {
            return "Unconfirmed Transactions"
        } else {
            return transactionSections[unconfirmedTransactions.count > 0 ? section - 2 : section - 1]
        }
    }
}
