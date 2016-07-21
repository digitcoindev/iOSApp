//
//  MessagesButtonTypeOne.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 17.08.15.
//  Copyright (c) 2015 Artygeek. All rights reserved.
//

import UIKit

class MessagesButtonTypeOne: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
            titleLabel.frame.origin.x = (self.frame.width / 2 - titleLabel.frame.width) / 2
            titleLabel.frame.origin.y = (self.frame.height - titleLabel.frame.height) / 2
        }
        
        if let imageView = self.imageView {
            imageView.contentMode =  UIViewContentMode.ScaleAspectFit
            imageView.frame = CGRect(x: titleLabel!.frame.origin.x + titleLabel!.frame.width + 5, y: 0, width: self.frame.width / 2 , height: self.frame.height)
        }
    }
}
