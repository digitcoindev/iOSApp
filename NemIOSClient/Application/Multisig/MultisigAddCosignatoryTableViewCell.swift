//
//  MultisigAddCosignatoryTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

/// The table view cell that lets the user add a new multisig cosigner.
class MultisigAddCosignatoryTableViewCell: UITableViewCell {

    // MARK: - Cell Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateCellAppearance()
    }
    
    // MARK: - Cell Helper Methods
    
    /// Updates the appearance of the table view cell.
    fileprivate func updateCellAppearance() {
        
        titleLabel.text = "ADD_ADITIONAL_SIGNER".localized()
        
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }
}
