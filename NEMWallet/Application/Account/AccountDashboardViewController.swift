//
//  AccountDashboardViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit
import SwiftyJSON

///
final class AccountDashboardViewController: UIViewController {
    
    // MARK: - View Controller Properties

    ///
    fileprivate var unconfirmedTransactions = [Transaction]()
    
    ///
    fileprivate var transactions = [Transaction]()
    
    var account: Account?
    fileprivate var accountData: AccountData?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var unconfirmedTransactionsTableView: UITableView!
    @IBOutlet weak var transactionsTableView: UITableView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountManager.sharedInstance.activeAccount
        
        fetchTransactions()
        fetchUnconfirmedTransactions()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads the account dashboard with the newest data.
    private func reloadAccountDashboard() {
        
        unconfirmedTransactionsTableView.reloadData()
        transactionsTableView.reloadData()
    }
    
    /// Fetches the last 25 transactions for the current account.
    private func fetchTransactions() {
        
        NEMProvider.request(NEM.transactions(accountAddress: account!.address, server: nil)) { [weak self] (result) in
            
            switch result {
            case let .success(response):
                
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    
                    let json = JSON(data: response.data)
                    var transactions = [Transaction]()
                    
                    for (_, subJson) in json["data"] {
                        
                        switch subJson["transaction"]["type"].intValue {
                        case TransactionType.transferTransaction.rawValue:
                            
                            let transferTransaction = try subJson.mapObject(TransferTransaction.self)
                            transactions.append(transferTransaction)
                            
                        case TransactionType.multisigTransaction.rawValue:
                            
                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
                            case TransactionType.transferTransaction.rawValue:
                                
                                let multisigTransaction = try subJson.mapObject(MultisigTransaction.self)
                                let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction
                                transactions.append(transferTransaction)
                                
                            default:
                                break
                            }
                            
                        default:
                            break
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self?.transactions = transactions
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
        
//        accountDashboardDispatchGroup.enter()
//        
//        NEMProvider.request(NEM.unconfirmedTransactions(accountAddress: account!.address, server: nil)) { [weak self] (result) in
//            
//            var needToSign = false
//            
//            switch result {
//            case let .success(response):
//                
//                do {
//                    let _ = try response.filterSuccessfulStatusCodes()
//                    
//                    let json = JSON(data: response.data)
//                    var unconfirmedTransactions = [Transaction]()
//                    
//                    for (_, subJson) in json["data"] {
//                        
//                        switch subJson["transaction"]["type"].intValue {
//                        case TransactionType.transferTransaction.rawValue:
//                            
//                            let transferTransaction = try subJson.mapObject(TransferTransaction.self)
//                            unconfirmedTransactions.append(transferTransaction)
//                            
//                        case TransactionType.multisigTransaction.rawValue:
//                            
//                            var foundSignature = false
//                            
//                            let multisigTransaction = try subJson.mapObject(MultisigTransaction.self)
//                            
//                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
//                            case TransactionType.transferTransaction.rawValue:
//                                
//                                let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction
//                                unconfirmedTransactions.append(transferTransaction)
//                                
//                                if transferTransaction.recipient == account.address || transferTransaction.signer == account.publicKey {
//                                    foundSignature = true
//                                }
//                                
//                            case TransactionType.multisigAggregateModificationTransaction.rawValue:
//                                
//                                let multisigAggregateModificationTransaction = multisigTransaction.innerTransaction as! MultisigAggregateModificationTransaction
//                                
//                                for modification in multisigAggregateModificationTransaction.modifications where modification.cosignatoryAccount == account.publicKey {
//                                    foundSignature = true
//                                }
//                                
//                                if multisigAggregateModificationTransaction.signer == account.publicKey {
//                                    foundSignature = true
//                                }
//                                
//                            default:
//                                
//                                foundSignature = true
//                                break
//                            }
//                            
//                            if multisigTransaction.signer == account.publicKey {
//                                foundSignature = true
//                            }
//                            for signature in multisigTransaction.signatures! where signature.signer == account.publicKey {
//                                foundSignature = true
//                            }
//                            
//                            if foundSignature == false {
//                                needToSign = true
//                            }
//                            
//                        default:
//                            break
//                        }
//                    }
//                    
//                    DispatchQueue.main.async {
//                        
//                        self?.transactions += unconfirmedTransactions
//                        
//                        self?.accountDashboardDispatchGroup.leave()
//                        
//                        if self != nil {
//                            if needToSign && self!.showSignTransactionsAlert {
//                                
//                                let alert = UIAlertController(title: "INFO".localized(), message: "UNCONFIRMED_TRANSACTIONS_DETECTED".localized(), preferredStyle: UIAlertControllerStyle.alert)
//                                
//                                let alertCancelAction = UIAlertAction(title: "REMIND_LATER".localized(), style: UIAlertActionStyle.default, handler: { (action) in
//                                    
//                                    self?.showSignTransactionsAlert = false
//                                })
//                                alert.addAction(alertCancelAction)
//                                
//                                let alertShowUnsignedTransactionsAction = UIAlertAction(title: "SHOW_TRANSACTIONS".localized(), style: UIAlertActionStyle.default, handler: { (action) in
//                                    
//                                    self?.showSignTransactionsAlert = false
//                                    self?.performSegue(withIdentifier: "showTransactionUnconfirmedViewController", sender: nil)
//                                })
//                                alert.addAction(alertShowUnsignedTransactionsAction)
//                                
//                                self?.present(alert, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                    
//                } catch {
//                    
//                    DispatchQueue.main.async {
//                        
//                        print("Failure: \(response.statusCode)")
//                        
//                        self?.accountDashboardDispatchGroup.leave()
//                    }
//                }
//                
//            case let .failure(error):
//                
//                DispatchQueue.main.async {
//                    
//                    print(error)
//                    self?.updateInfoHeaderLabel(withAccountData: nil)
//                    
//                    self?.accountDashboardDispatchGroup.leave()
//                }
//            }
//        }
    }
}

extension AccountDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case unconfirmedTransactionsTableView:
            return unconfirmedTransactions.count
        case transactionsTableView:
            return transactions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let transaction = transactions[indexPath.row] as! TransferTransaction
        
        let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        transactionTableViewCell.transactionCorrespondentLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transaction.signer)
        transactionTableViewCell.transactionAmountLabel.text = transaction.amount.format()
        transactionTableViewCell.transactionMessageLabel.text = transaction.message?.message ?? ""
        transactionTableViewCell.transactionDateLabel.text = transaction.timeStamp.format()
        
        return transactionTableViewCell
    }
}
