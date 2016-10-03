//
//  Server+Additions.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation

extension Server {
    
    func fullURL() -> String {
        return "\(self.protocolType)://\(self.address):\(self.port)"
    }
}
