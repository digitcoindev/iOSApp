//
//  SaveCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 28.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class MultisignatureSaveChangesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var saveButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        saveButton.setTitle("SAVE_CHANGES".localized(), forState: UIControlState.Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
