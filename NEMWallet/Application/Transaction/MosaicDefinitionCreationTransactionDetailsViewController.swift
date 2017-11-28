//
//  MosaicDefinitionCreationTransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class MosaicDefinitionCreationTransactionDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var mosaicDefinitionCreationTransaction: MosaicDefinitionCreationTransaction?
    
    // MARK: - View Controller Outlets
    
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var transactionNewMosaicLabel: UILabel!
    @IBOutlet weak var transactionMosaicDescriptionLabel: UILabel!
    @IBOutlet weak var transactionMosaicInitialSupplyLabel: UILabel!
    @IBOutlet weak var transactionMosaicSupplyIsMutableLabel: UILabel!
    @IBOutlet weak var transactionMosaicIsTransferableLabel: UILabel!
    @IBOutlet weak var transactionCreationFeeLabel: UILabel!
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
        
        if let mosaicDefinitionCreationTransaction = mosaicDefinitionCreationTransaction {
            switch mosaicDefinitionCreationTransaction.type {
            case .mosaicDefinitionCreationTransaction:
                
                transactionTypeLabel.text = "Mosaic Definition Creation Transaction"
                transactionDateLabel.text = mosaicDefinitionCreationTransaction.timeStamp.format()
                transactionNewMosaicLabel.text = "\(mosaicDefinitionCreationTransaction.mosaicDefinition.namespace!):\(mosaicDefinitionCreationTransaction.mosaicDefinition.name!)"
                transactionMosaicDescriptionLabel.text = mosaicDefinitionCreationTransaction.mosaicDefinition.description
                transactionMosaicInitialSupplyLabel.text = mosaicDefinitionCreationTransaction.mosaicDefinition.initialSupply.format(fractionDigits: mosaicDefinitionCreationTransaction.mosaicDefinition.divisibility)
                transactionMosaicSupplyIsMutableLabel.text = mosaicDefinitionCreationTransaction.mosaicDefinition.supplyIsMutable ? "Yes" : "No"
                transactionMosaicIsTransferableLabel.text = mosaicDefinitionCreationTransaction.mosaicDefinition.isTransferable ? "Yes" : "No"
                transactionCreationFeeLabel.text = "\(mosaicDefinitionCreationTransaction.creationFee.format()) XEM"
                transactionCreationFeeLabel.textColor = Constants.outgoingColor
                transactionFeeLabel.text = "\(mosaicDefinitionCreationTransaction.fee.format()) XEM"
                transactionBlockHeightLabel.text = mosaicDefinitionCreationTransaction.metaData?.height != nil ? "\(mosaicDefinitionCreationTransaction.metaData!.height!)" : "-"
                transactionHashLabel.text = mosaicDefinitionCreationTransaction.metaData?.hash != "" ? "\(mosaicDefinitionCreationTransaction.metaData?.hash ?? "-")" : "-"
                
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
