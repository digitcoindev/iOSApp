//
//  MessageUILabel.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 16.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class MessageUILabel: UILabel {
    override func drawText(in rect: CGRect) {
        let newRect = CGRect(x: rect.origin.x + 5, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
        
        super.drawText(in: newRect)
    }
    override func sizeToFit() {
        super.sizeToFit()
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width + 10, height: self.frame.size.height + 10)
    }
}
