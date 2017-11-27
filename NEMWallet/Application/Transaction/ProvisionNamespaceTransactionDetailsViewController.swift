//
//  ProvisionNamespaceTransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class ProvisionNamespaceTransactionDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var provisionNamespaceTransaction: ProvisionNamespaceTransaction?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var transactionNewNamespaceLabel: UILabel!
    @IBOutlet weak var transactionRentalFeeLabel: UILabel!
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
        
        if let provisionNamespaceTransaction = provisionNamespaceTransaction {
            switch provisionNamespaceTransaction.type {
            case .provisionNamespaceTransaction:
                
                transactionTypeLabel.text = "Provision Namespace Transaction"
                transactionDateLabel.text = provisionNamespaceTransaction.timeStamp.format()
                transactionNewNamespaceLabel.text = provisionNamespaceTransaction.parent != nil ? "\(provisionNamespaceTransaction.parent!).\(provisionNamespaceTransaction.newPart!)" : provisionNamespaceTransaction.newPart
                transactionRentalFeeLabel.text = "\(provisionNamespaceTransaction.rentalFee.format()) XEM"
                transactionRentalFeeLabel.textColor = Constants.outgoingColor
                transactionFeeLabel.text = "\(provisionNamespaceTransaction.fee.format()) XEM"
                transactionBlockHeightLabel.text = provisionNamespaceTransaction.metaData?.height != nil ? "\(provisionNamespaceTransaction.metaData!.height!)" : "-"
                transactionHashLabel.text = provisionNamespaceTransaction.metaData?.hash != "" ? "\(provisionNamespaceTransaction.metaData?.hash ?? "-")" : "-"
                
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
