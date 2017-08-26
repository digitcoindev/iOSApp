//
//  TransactionTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/// A table view cell representing a transaction on the account dashboard.
final class TransactionTableViewCell: UITableViewCell {
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var transactionCorrespondentLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var transactionMessageLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
}
