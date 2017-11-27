//
//  TransactionAssetTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/// A table view cell representing an asset that god transferred within a transfer transaction.
final class TransactionAssetTableViewCell: UITableViewCell {
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var transactionAssetNameLabel: UILabel!
    @IBOutlet weak var transactionAssetAmountLabel: UILabel!
}
