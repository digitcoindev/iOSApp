//
//  CosigTableViewCell.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 23.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class CosigTableViewCell: EditableTableViewCell {
    
    // MARK: properties
    
    let infoLabel: UILabel = UILabel()
    
    // MARK: inizializers
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoLabel.text = "loading ..."
        infoLabel.numberOfLines = 2
        
        _contentView?.addSubview(infoLabel)
    }

    // MARK: layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var _accum = _editView!.frame.width
        _editView?.frame = CGRect(x: -_accum, y: 0, width: _accum, height: self.frame.height)
        
        _accum = _editView!.frame.origin.x + _editView!.frame.width
        
        _contentView?.frame = CGRect(x: _accum, y: 0, width: _deleteView!.frame.origin.x - _accum, height: self.frame.height)
        
        infoLabel.frame = CGRect(x: _SEPARATOR_OFFSET_, y: 0, width: _contentView!.frame.width - _SEPARATOR_OFFSET_ * 2 , height: _contentView!.frame.height)
    }
}
