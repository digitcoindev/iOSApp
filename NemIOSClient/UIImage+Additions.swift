//
//  UIImage+Additions.swift
//  NEMIOSClient
//
//  Created by Thomas Oehri on 25.04.16.
//  Copyright © 2016 Gospore. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /**
     Changes the color of the image to the specified UIColor.
     */
    func imageWithColor(tintColor: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, .Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}