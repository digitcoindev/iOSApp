//
//  TextFieldTableViewCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 22.01.16.
//  Copyright © 2016 Artygeek. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet var textField :UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
