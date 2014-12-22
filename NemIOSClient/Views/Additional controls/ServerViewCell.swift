//
//  ServerViewCell.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 11.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class ServerViewCell: UITableViewCell
{
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var serverAddress: UILabel!

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
