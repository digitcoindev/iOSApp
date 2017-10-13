//
//  TransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class TransactionDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var accountBalance = Double()
    public var accountFiatBalance = Double()
    public var transaction: Transaction?

    // MARK: - View Controller Outlets
    
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountFiatBalanceLabel: UILabel!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var signerLabel: UILabel!
    @IBOutlet weak var transactionSignerLabel: UILabel!
    @IBOutlet weak var transactionRecipientLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionMessageLabel: UILabel!
    @IBOutlet weak var transactionBlockHeightLabel: UILabel!
    @IBOutlet weak var transactionHashLabel: UILabel!
    @IBOutlet weak var createResponseTransactionButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadTransactionDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTransactionDetails), name: Constants.transactionDataChangedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads all transaction details with the newest data.
    internal func reloadTransactionDetails() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        accountTitleLabel.text = account?.title ?? ""
        accountBalanceLabel.text = "\(accountBalance.format()) XEM"
        accountFiatBalanceLabel.text = numberFormatter.string(from: accountFiatBalance as NSNumber)
        
        guard transaction != nil else { return }
        
        switch transaction!.type {
        case .transferTransaction:
            
            let transferTransaction = transaction as! TransferTransaction
            
            transactionTypeLabel.text = transferTransaction.transferType == .incoming ? "Incoming Transaction" : "Outgoing Transaction"
            transactionDateLabel.text = transferTransaction.timeStamp.format()
            transactionSignerLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer).nemAddressNormalised()
            transactionRecipientLabel.text = transferTransaction.recipient.nemAddressNormalised()
            
            if transferTransaction.transferType == .incoming {
                transactionAmountLabel.text = "+\(transferTransaction.amount.format()) XEM"
                transactionAmountLabel.textColor = Constants.incomingColor
            } else if transferTransaction.transferType == .outgoing {
                transactionAmountLabel.text = "-\(transferTransaction.amount.format()) XEM"
                transactionAmountLabel.textColor = Constants.outgoingColor
            }
            
            transactionFeeLabel.text = "\(transferTransaction.fee.format()) XEM"
            transactionMessageLabel.text = transferTransaction.message?.message ?? ""
            transactionBlockHeightLabel.text = transferTransaction.metaData?.height != nil ? "\(transferTransaction.metaData!.height!)" : ""
            transactionHashLabel.text = "\(transferTransaction.metaData?.hash ?? "")"
            
        case .multisigTransaction:
            
            let multisigTransaction = transaction as! MultisigTransaction
            
            switch multisigTransaction.innerTransaction.type {
            case .transferTransaction:
                
                let transferTransaction = multisigTransaction.innerTransaction as! TransferTransaction
                
                signerLabel.text = "From Multisig Account"
                transactionTypeLabel.text = transferTransaction.transferType == .incoming ? "Incoming Multisig Transaction" : "Outgoing Multisig Transaction"
                transactionDateLabel.text = transferTransaction.timeStamp.format()
                transactionSignerLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer).nemAddressNormalised()
                transactionRecipientLabel.text = transferTransaction.recipient.nemAddressNormalised()
                
                if transferTransaction.transferType == .incoming {
                    transactionAmountLabel.text = "+\(transferTransaction.amount.format()) XEM"
                    transactionAmountLabel.textColor = Constants.incomingColor
                } else if transferTransaction.transferType == .outgoing {
                    transactionAmountLabel.text = "-\(transferTransaction.amount.format()) XEM"
                    transactionAmountLabel.textColor = Constants.outgoingColor
                }
                
                transactionFeeLabel.text = "\(transferTransaction.fee.format()) XEM"
                transactionMessageLabel.text = transferTransaction.message?.message ?? ""
                transactionBlockHeightLabel.text = transferTransaction.metaData?.height != nil ? "\(transferTransaction.metaData!.height!)" : ""
                transactionHashLabel.text = "\(transferTransaction.metaData?.hash ?? "")"
                
            default:
                break
            }
            
            
        default:
            break
        }
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        createResponseTransactionButton.layer.cornerRadius = 10.0
    }
}
