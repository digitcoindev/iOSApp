//
//  AddCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 28.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class AddCell: UITableViewCell {

    @IBOutlet weak var addLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addLabel.text = "ADD_ADITIONAL_SIGNER".localized()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
