//
//  AbstactTableViewCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 16.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class AbstactTableViewCell: UITableViewCell {
    
    // MARK: internal variables
    internal let _contentView: UIView? = UIView()
    
    internal let _SMALL_OFFSET_ :CGFloat = 2
    internal let _SEPARATOR_OFFSET_ :CGFloat = 15

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(_contentView!)
    }
    
    // MARK: layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _contentView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
