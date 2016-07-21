//
//  ProfileTableViewCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 21.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var contentLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
