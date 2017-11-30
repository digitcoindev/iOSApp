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
    
    /// The latest market info, used to display fiat account balances.
    public var marketInfo: (xemPrice: Double, btcPrice: Double) = (0, 0)
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var createTransactionButton: UIBarButtonItem!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = AccountManager.sharedInstance.activeAccount
        
        tableView.estimatedRowHeight = 110.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        if accountData?.cosignatories?.count ?? 0 > 0 {
            createTransactionButton.isEnabled = false
        } else {
            createTransactionButton.isEnabled = true
        }
        
        fetchConfirmedTransactions()
        fetchUnconfirmedTransactions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAccountDashboard), name: Constants.transactionDataChangedNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "showAccountDetailsViewController":
            
            let destinationViewController = segue.destination as! AccountDetailsViewController
            destinationViewController.account = account
            destinationViewController.accountBalance = accountBalance
            destinationViewController.accountFiatBalance = accountFiatBalance
            destinationViewController.accountData = accountData
            
        case "showTransferTransactionDetailsViewController", "showMultisigTransferTransactionDetailsViewController", "showImportanceTransferTransactionDetailsViewController", "showMultisigImportanceTransferTransactionDetailsViewController", "showProvisionNamespaceTransactionDetailsViewController", "showMultisigProvisionNamespaceTransactionDetailsViewController", "showMosaicDefinitionCreationTransactionDetailsViewController", "showMultisigMosaicDefinitionCreationTransactionDetailsViewController":
            
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                
                var transaction: Transaction!
                if unconfirmedTransactions.count > 0 && indexPathForSelectedRow.section == 1 {
                    transaction = unconfirmedTransactions[indexPathForSelectedRow.row]
                } else {
                    let section = transactionSections[unconfirmedTransactions.count > 0 ? indexPathForSelectedRow.section - 2 : indexPathForSelectedRow.section - 1]
                    transaction = confirmedTransactionsBySection[section]![indexPathForSelectedRow.row]
                }
                
                if segue.identifier == "showTransferTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! TransferTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.transferTransaction = transaction as? TransferTransaction
                    
                } else if segue.identifier == "showMultisigTransferTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! MultisigTransferTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.multisigTransaction = transaction as? MultisigTransaction
                    
                } else if segue.identifier == "showImportanceTransferTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! ImportanceTransferTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.importanceTransferTransaction = transaction as? ImportanceTransferTransaction
                    
                } else if segue.identifier == "showMultisigImportanceTransferTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! MultisigImportanceTransferTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.multisigTransaction = transaction as? MultisigTransaction
                    
                } else if segue.identifier == "showProvisionNamespaceTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! ProvisionNamespaceTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.provisionNamespaceTransaction = transaction as? ProvisionNamespaceTransaction
                    
                } else if segue.identifier == "showMultisigProvisionNamespaceTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! MultisigProvisionNamespaceTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.multisigTransaction = transaction as? MultisigTransaction
                    
                } else if segue.identifier == "showMosaicDefinitionCreationTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! MosaicDefinitionCreationTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.mosaicDefinitionCreationTransaction = transaction as? MosaicDefinitionCreationTransaction
                    
                } else if segue.identifier == "showMultisigMosaicDefinitionCreationTransactionDetailsViewController" {
                    let destinationViewController = segue.destination as! MultisigMosaicDefinitionCreationTransactionDetailsViewController
                    destinationViewController.account = account
                    destinationViewController.multisigTransaction = transaction as? MultisigTransaction
                }
            }
            
        case "showSendViewController":
            
            let destinationViewController = segue.destination as! SendViewController
            destinationViewController.account = account
            destinationViewController.accountBalance = accountBalance
            destinationViewController.accountFiatBalance = accountFiatBalance
            destinationViewController.marketInfo = marketInfo
            
        default:
            return
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads the account dashboard with the newest data.
    @objc internal func reloadAccountDashboard() {
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
                            
                        case TransactionType.importanceTransferTransaction.rawValue:
                            
                            let importanceTransferTransaction = try subJson.mapObject(ImportanceTransferTransaction.self)
                            let sectionTitle = importanceTransferTransaction.timeStamp.sectionTitle()
                            
                            if confirmedTransactionsBySection[sectionTitle] == nil {
                                confirmedTransactionsBySection[sectionTitle] = [Transaction]()
                                transactionSections.append(sectionTitle)
                            }
                            
                            confirmedTransactionsBySection[sectionTitle]?.append(importanceTransferTransaction)
                            
                        case TransactionType.provisionNamespaceTransaction.rawValue:
                            
                            let provisionNamespaceTransaction = try subJson.mapObject(ProvisionNamespaceTransaction.self)
                            let sectionTitle = provisionNamespaceTransaction.timeStamp.sectionTitle()
                            
                            if confirmedTransactionsBySection[sectionTitle] == nil {
                                confirmedTransactionsBySection[sectionTitle] = [Transaction]()
                                transactionSections.append(sectionTitle)
                            }
                            
                            confirmedTransactionsBySection[sectionTitle]?.append(provisionNamespaceTransaction)
                            
                        case TransactionType.mosaicDefinitionCreationTransaction.rawValue:
                            
                            let mosaicDefinitionCreationTransaction = try subJson.mapObject(MosaicDefinitionCreationTransaction.self)
                            let sectionTitle = mosaicDefinitionCreationTransaction.timeStamp.sectionTitle()
                            
                            if confirmedTransactionsBySection[sectionTitle] == nil {
                                confirmedTransactionsBySection[sectionTitle] = [Transaction]()
                                transactionSections.append(sectionTitle)
                            }
                            
                            confirmedTransactionsBySection[sectionTitle]?.append(mosaicDefinitionCreationTransaction)
                            
                        case TransactionType.multisigTransaction.rawValue:
                            
                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
                            case TransactionType.transferTransaction.rawValue, TransactionType.importanceTransferTransaction.rawValue, TransactionType.provisionNamespaceTransaction.rawValue, TransactionType.mosaicDefinitionCreationTransaction.rawValue:
                                
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
                            
                        case TransactionType.importanceTransferTransaction.rawValue:
                            
                            let importanceTransferTransaction = try subJson.mapObject(ImportanceTransferTransaction.self)
                            unconfirmedTransactions.append(importanceTransferTransaction)
                            
                        case TransactionType.provisionNamespaceTransaction.rawValue:
                            
                            let provisionNamespaceTransaction = try subJson.mapObject(ProvisionNamespaceTransaction.self)
                            unconfirmedTransactions.append(provisionNamespaceTransaction)
                            
                        case TransactionType.mosaicDefinitionCreationTransaction.rawValue:
                            
                            let mosaicDefinitionCreationTransaction = try subJson.mapObject(ProvisionNamespaceTransaction.self)
                            unconfirmedTransactions.append(mosaicDefinitionCreationTransaction)
                            
                        case TransactionType.multisigTransaction.rawValue:
                            
                            switch subJson["transaction"]["otherTrans"]["type"].intValue {
                            case TransactionType.transferTransaction.rawValue, TransactionType.importanceTransferTransaction.rawValue, TransactionType.provisionNamespaceTransaction.rawValue, TransactionType.mosaicDefinitionCreationTransaction.rawValue:
                                
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
    
    // MARK: - View Controller Outlet Actions
    
    @IBAction func unwindToAccountDashboardViewController(_ sender: UIStoryboardSegue) {
        fetchConfirmedTransactions()
        fetchUnconfirmedTransactions()
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
                
            case TransactionType.importanceTransferTransaction:
                
                let importanceTransferTransaction = transaction as! ImportanceTransferTransaction
                
                let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                transactionTableViewCell.transactionCorrespondentLabel.text = "Importance Transfer"
                transactionTableViewCell.transactionCorrespondentLabel.lineBreakMode = .byTruncatingTail
                transactionTableViewCell.transactionDateLabel.text = importanceTransferTransaction.timeStamp.format()
                transactionTableViewCell.transactionMessageLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: importanceTransferTransaction.remoteAccount).nemAddressNormalised()
                transactionTableViewCell.transactionMessageLabel.lineBreakMode = .byTruncatingMiddle

                if importanceTransferTransaction.mode == 1 {
                    transactionTableViewCell.transactionAmountLabel.text = "Activation"
                    transactionTableViewCell.transactionAmountLabel.textColor = Constants.incomingColor
                } else {
                    transactionTableViewCell.transactionAmountLabel.text = "Deactivation"
                    transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                }
                
                if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                    transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                } else {
                    transactionTableViewCell.backgroundColor = UIColor.white
                }
                
                return transactionTableViewCell
                
            case TransactionType.provisionNamespaceTransaction:
                
                let provisionNamespaceTransaction = transaction as! ProvisionNamespaceTransaction
                
                let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                transactionTableViewCell.transactionCorrespondentLabel.text = "Create Namespace"
                transactionTableViewCell.transactionCorrespondentLabel.lineBreakMode = .byTruncatingTail
                transactionTableViewCell.transactionDateLabel.text = provisionNamespaceTransaction.timeStamp.format()
                transactionTableViewCell.transactionAmountLabel.text = "-\(provisionNamespaceTransaction.rentalFee.format()) XEM"
                transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                transactionTableViewCell.transactionMessageLabel.text = provisionNamespaceTransaction.parent != nil ? "\(provisionNamespaceTransaction.parent!).\(provisionNamespaceTransaction.newPart!)" : provisionNamespaceTransaction.newPart
                
                if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                    transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                } else {
                    transactionTableViewCell.backgroundColor = UIColor.white
                }
                
                return transactionTableViewCell
                
            case TransactionType.mosaicDefinitionCreationTransaction:
                
                let mosaicDefinitionCreationTransaction = transaction as! MosaicDefinitionCreationTransaction
                
                let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                transactionTableViewCell.transactionCorrespondentLabel.text = "Create Asset"
                transactionTableViewCell.transactionCorrespondentLabel.lineBreakMode = .byTruncatingTail
                transactionTableViewCell.transactionDateLabel.text = mosaicDefinitionCreationTransaction.timeStamp.format()
                transactionTableViewCell.transactionAmountLabel.text = "-\(mosaicDefinitionCreationTransaction.creationFee.format()) XEM"
                transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                transactionTableViewCell.transactionMessageLabel.text = "\(mosaicDefinitionCreationTransaction.mosaicDefinition.namespace!):\(mosaicDefinitionCreationTransaction.mosaicDefinition.name!)"
                
                if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                    transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                } else {
                    transactionTableViewCell.backgroundColor = UIColor.white
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
                    
                case TransactionType.importanceTransferTransaction:
                    
                    let importanceTransferTransaction = multisigTransaction.innerTransaction as! ImportanceTransferTransaction
                    
                    let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                    transactionTableViewCell.transactionCorrespondentLabel.text = "Importance Transfer"
                    transactionTableViewCell.transactionCorrespondentLabel.lineBreakMode = .byTruncatingTail
                    transactionTableViewCell.transactionDateLabel.text = importanceTransferTransaction.timeStamp.format()
                    transactionTableViewCell.transactionMessageLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: importanceTransferTransaction.remoteAccount).nemAddressNormalised()
                    transactionTableViewCell.transactionMessageLabel.lineBreakMode = .byTruncatingMiddle
                    
                    if importanceTransferTransaction.mode == 1 {
                        transactionTableViewCell.transactionAmountLabel.text = "Activation"
                        transactionTableViewCell.transactionAmountLabel.textColor = Constants.incomingColor
                    } else {
                        transactionTableViewCell.transactionAmountLabel.text = "Deactivation"
                        transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                    }
                    
                    if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                        transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                    } else {
                        transactionTableViewCell.backgroundColor = UIColor.white
                    }
                    
                    return transactionTableViewCell
                    
                case TransactionType.provisionNamespaceTransaction:
                    
                    let provisionNamespaceTransaction = multisigTransaction.innerTransaction as! ProvisionNamespaceTransaction
                    
                    let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                    transactionTableViewCell.transactionCorrespondentLabel.text = "Create Namespace"
                    transactionTableViewCell.transactionCorrespondentLabel.lineBreakMode = .byTruncatingTail
                    transactionTableViewCell.transactionDateLabel.text = provisionNamespaceTransaction.timeStamp.format()
                    transactionTableViewCell.transactionAmountLabel.text = "-\(provisionNamespaceTransaction.rentalFee.format()) XEM"
                    transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                    transactionTableViewCell.transactionMessageLabel.text = provisionNamespaceTransaction.parent != nil ? "\(provisionNamespaceTransaction.parent!).\(provisionNamespaceTransaction.newPart!)" : provisionNamespaceTransaction.newPart
                    
                    if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                        transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                    } else {
                        transactionTableViewCell.backgroundColor = UIColor.white
                    }
                    
                    return transactionTableViewCell
                    
                case TransactionType.mosaicDefinitionCreationTransaction:
                    
                    let mosaicDefinitionCreationTransaction = multisigTransaction.innerTransaction as! MosaicDefinitionCreationTransaction
                    
                    let transactionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
                    transactionTableViewCell.transactionCorrespondentLabel.text = "Create Asset"
                    transactionTableViewCell.transactionCorrespondentLabel.lineBreakMode = .byTruncatingTail
                    transactionTableViewCell.transactionDateLabel.text = mosaicDefinitionCreationTransaction.timeStamp.format()
                    transactionTableViewCell.transactionAmountLabel.text = "-\(mosaicDefinitionCreationTransaction.creationFee.format()) XEM"
                    transactionTableViewCell.transactionAmountLabel.textColor = Constants.outgoingColor
                    transactionTableViewCell.transactionMessageLabel.text = "\(mosaicDefinitionCreationTransaction.mosaicDefinition.namespace!):\(mosaicDefinitionCreationTransaction.mosaicDefinition.name!)"
                    
                    if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
                        transactionTableViewCell.backgroundColor = Constants.nemLightOrangeColor
                    } else {
                        transactionTableViewCell.backgroundColor = UIColor.white
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let transaction: Transaction!
        if indexPath.section == 0 {
            return
        } else if unconfirmedTransactions.count > 0 && indexPath.section == 1 {
            transaction = unconfirmedTransactions[indexPath.row]
        } else {
            let section = transactionSections[unconfirmedTransactions.count > 0 ? indexPath.section - 2 : indexPath.section - 1]
            transaction = confirmedTransactionsBySection[section]![indexPath.row]
        }
        
        switch transaction.type {
        case .transferTransaction:
            performSegue(withIdentifier: "showTransferTransactionDetailsViewController", sender: nil)
            
        case .importanceTransferTransaction:
            performSegue(withIdentifier: "showImportanceTransferTransactionDetailsViewController", sender: nil)
            
        case .provisionNamespaceTransaction:
            performSegue(withIdentifier: "showProvisionNamespaceTransactionDetailsViewController", sender: nil)
            
        case .mosaicDefinitionCreationTransaction:
            performSegue(withIdentifier: "showMosaicDefinitionCreationTransactionDetailsViewController", sender: nil)
            
        case .multisigTransaction:
            
            let multisigTransaction = transaction as! MultisigTransaction
            
            switch multisigTransaction.innerTransaction.type {
            case .transferTransaction:
                performSegue(withIdentifier: "showMultisigTransferTransactionDetailsViewController", sender: nil)
            case .importanceTransferTransaction:
                performSegue(withIdentifier: "showMultisigImportanceTransferTransactionDetailsViewController", sender: nil)
            case .provisionNamespaceTransaction:
                performSegue(withIdentifier: "showMultisigProvisionNamespaceTransactionDetailsViewController", sender: nil)
            case .mosaicDefinitionCreationTransaction:
                performSegue(withIdentifier: "showMultisigMosaicDefinitionCreationTransactionDetailsViewController", sender: nil)
            default:
                break
            }
            
        default:
            break
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
