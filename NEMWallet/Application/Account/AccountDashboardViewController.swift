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
final class AccountDashboardViewController: UIViewController {
    
    // MARK: - View Controller Properties

    ///
    fileprivate var unconfirmedTransactions = [Transaction]()
    
    ///
    fileprivate var confirmedTransactionsBySection = [String: [Transaction]]()
    
    ///
    fileprivate var transactionSections = [String]()
    
    var account: Account?
    fileprivate var accountData: AccountData?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var transactionsTableView: UITableView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountManager.sharedInstance.activeAccount
        
        transactionsTableView.estimatedRowHeight = 110.0
        transactionsTableView.rowHeight = UITableViewAutomaticDimension
        
        fetchConfirmedTransactions()
        fetchUnconfirmedTransactions()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads the account dashboard with the newest data.
    private func reloadAccountDashboard() {
        transactionsTableView.reloadData()
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
                                let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction
                                let sectionTitle = transferTransaction.timeStamp.sectionTitle()
                                
                                if confirmedTransactionsBySection[sectionTitle] == nil {
                                    confirmedTransactionsBySection[sectionTitle] = [Transaction]()
                                    transactionSections.append(sectionTitle)
                                }
                                
                                confirmedTransactionsBySection[sectionTitle]?.append(transferTransaction)
                                
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
                                let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction
                                unconfirmedTransactions.append(transferTransaction)
                                
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

extension AccountDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if unconfirmedTransactions.count > 0 {
            return transactionSections.count + 1
        } else {
            return transactionSections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if unconfirmedTransactions.count > 0 && section == 0 {
            return unconfirmedTransactions.count
        } else {
            return confirmedTransactionsBySection[transactionSections[unconfirmedTransactions.count > 0 ? section - 1 : section]]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let transaction: TransferTransaction!
        if unconfirmedTransactions.count > 0 && indexPath.section == 0 {
            transaction = unconfirmedTransactions[indexPath.row] as! TransferTransaction
        } else {
            transaction = confirmedTransactionsBySection[transactionSections[unconfirmedTransactions.count > 0 ? indexPath.section - 1 : indexPath.section]]?[indexPath.row] as! TransferTransaction
        }
        
        let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        transactionTableViewCell.transactionCorrespondentLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transaction.signer)
        transactionTableViewCell.transactionAmountLabel.text = transaction.amount.format()
        transactionTableViewCell.transactionMessageLabel.text = transaction.message?.message ?? ""
        transactionTableViewCell.transactionDateLabel.text = transaction.timeStamp.format()
        
        return transactionTableViewCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if unconfirmedTransactions.count > 0 && section == 0 {
            return "Unconfirmed Transactions"
        } else {
            return transactionSections[unconfirmedTransactions.count > 0 ? section - 1 : section]
        }
    }
}
