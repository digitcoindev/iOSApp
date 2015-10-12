//
//  Enums.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 07.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

enum QRKeys: String {
    case Address = "address"
    case Name = "name"
    case Amount = "amount"
    case Message = "message"
    case DataType = "type"
    case Data = "data"
}

enum QRType: Int {
    case UserData = 1
    case Invoice = 2
    case AccountData = 3
}
