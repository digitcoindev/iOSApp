//
//  HarvestingBlockTableViewCell.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class HarvestingBlockTableViewCell: UITableViewCell {

    @IBOutlet weak var block: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var fee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
