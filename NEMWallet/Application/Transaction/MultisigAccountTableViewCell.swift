//
//  MultisigAccountTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/// The table view cell that represents a multisig account.
final class MultisigAccountTableViewCell: UITableViewCell {
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountFiatBalanceLabel: UILabel!
}
