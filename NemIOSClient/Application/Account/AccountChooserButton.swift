//
//  AccountChooserButton.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

class AccountChooserButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = UIColor(red: 51 / 256, green: 191 / 256, blue: 86 / 256, alpha: 1).CGColor
        self.layer.borderWidth = 1
        
        if let imageView = self.imageView {
            imageView.contentMode =  UIViewContentMode.ScaleAspectFit
            imageView.frame = CGRect(x: self.frame.width - self.frame.height * 0.75 - 5, y: self.frame.height * 0.125, width: self.frame.height * 0.75, height: self.frame.height * 0.75)
        }
        
        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
            titleLabel.frame.origin.x = 0
            titleLabel.frame.origin.y = 0
            titleLabel.frame = CGRect(x: 10, y: 0, width: self.frame.width - self.frame.height - 10, height: self.frame.height)

        }
    }
}
