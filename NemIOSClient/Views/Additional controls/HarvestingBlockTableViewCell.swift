//
//  BlockTableViewCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 29.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class HarvestingBlockTableViewCell: UITableViewCell {

    @IBOutlet weak var block: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var fee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
