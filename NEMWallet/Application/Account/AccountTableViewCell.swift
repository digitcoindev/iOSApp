//
//  AccountTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

/// The table view cell that represents an account.
final class AccountTableViewCell: UITableViewCell {
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountFiatBalanceLabel: UILabel!
    @IBOutlet weak var accountAssetsLabel: UILabel!
    @IBOutlet weak var accountAssetsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountFiatBalanceLabelBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Cell Helper Methods
    
    /// Shows the account assets summary. Call when the account owns assets.
    public func showAccountAssetsSummary() {
        
        accountAssetsLabelHeightConstraint.isActive = false
        accountFiatBalanceLabelBottomConstraint.constant = 10
    }
    
    /// Hides the account assets summary. Call when the account doesn't own any assets.
    public func hideAccountAssetsSummary() {
        
        accountAssetsLabelHeightConstraint.isActive = true
        accountFiatBalanceLabelBottomConstraint.constant = 0
    }
}
