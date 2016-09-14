//
//  UISegmentedControlExtensions.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 07.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    func removeBorders() {
        setDividerImage(imageWithColor(UIColor.clear), forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    fileprivate func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor);
        context?.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
