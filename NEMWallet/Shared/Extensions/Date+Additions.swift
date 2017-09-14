//
//  Date+Additions.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation

///
extension Date {
    
    ///
    func format() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        return dateFormatter.string(from: self)
    }
    
    ///
    func sectionTitle() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return dateFormatter.string(from: self)
    }
}
