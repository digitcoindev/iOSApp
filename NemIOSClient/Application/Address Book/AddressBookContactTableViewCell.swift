//
//  AddressBookContactTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import Contacts

/// The table view cell that represents a contact in the address book.
class AddressBookContactTableViewCell: UITableViewCell {
    
    // MARK: - Cell Properties
    
    var contact: CNContact! {
        didSet {
            updateCell()
        }
    }
    
    // MARK: - Cell Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Cell Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateCellAppearance()
    }
    
    // MARK: - Cell Helper Methods
    
    /// Updates the table view cell with the provided contact data.
    fileprivate func updateCell() {
        
        titleLabel.text = "\(contact.givenName) \(contact.familyName)"
    }
    
    /// Updates the appearance of the table view cell.
    fileprivate func updateCellAppearance() {
        
        titleLabel.text = String()
    }
}
