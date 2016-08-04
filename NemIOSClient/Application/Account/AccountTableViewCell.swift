//
//  AccountTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/// The table view cell that represents an account.
class AccountTableViewCell: UITableViewCell {
    
    // MARK: - Cell Properties
    
    /**
        The account title that will get shown as the
        title label of the table view cell.
     */
    var title: String? {
        didSet {
            updateCell()
        }
    }
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Cell Helper Methods
    
    /// Updates the table view cell with the provided title.
    private func updateCell() {
        
        titleLabel.text = title ?? String()
    }
}
