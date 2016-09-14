//
//  MultisigSaveChangesTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class MultisigSaveChangesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var saveButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        saveButton.setTitle("SAVE_CHANGES".localized(), for: UIControlState())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
