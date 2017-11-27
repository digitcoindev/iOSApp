//
//  ImportanceTransferTransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class ImportanceTransferTransactionDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var importanceTransferTransaction: ImportanceTransferTransaction?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var transactionRemoteAccountLabel: UILabel!
    @IBOutlet weak var transactionModeLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionBlockHeightLabel: UILabel!
    @IBOutlet weak var transactionHashLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadTransactionDetails()
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads all transaction details with the newest data.
    @objc internal func reloadTransactionDetails() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        if let importanceTransferTransaction = importanceTransferTransaction {
            switch importanceTransferTransaction.type {
            case .importanceTransferTransaction:
                
                transactionTypeLabel.text = "Importance Transfer Transaction"
                transactionDateLabel.text = importanceTransferTransaction.timeStamp.format()
                transactionRemoteAccountLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: importanceTransferTransaction.remoteAccount).nemAddressNormalised()

                if importanceTransferTransaction.mode == 1 {
                    transactionModeLabel.text = "Activation"
                    transactionModeLabel.textColor = Constants.incomingColor
                } else {
                    transactionModeLabel.text = "Deactivation"
                    transactionModeLabel.textColor = Constants.outgoingColor
                }

                transactionFeeLabel.text = "\(importanceTransferTransaction.fee.format()) XEM"
                transactionBlockHeightLabel.text = importanceTransferTransaction.metaData?.height != nil ? "\(importanceTransferTransaction.metaData!.height!)" : "-"
                transactionHashLabel.text = importanceTransferTransaction.metaData?.hash != "" ? "\(importanceTransferTransaction.metaData?.hash ?? "-")" : "-"
                
            default:
                break
            }
        }
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
}
