//
//  Enums.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 07.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

let QR_VERSION = 1

enum QRKeys: String {
    case Address = "addr"
    case Name = "name"
    case Amount = "amount"
    case Message = "msg"
    case DataType = "type"
    case Data = "data"
    case PrivateKey = "priv_key"
    case Salt = "salt"
    case Version = "v"
}

enum QRType: Int {
    case userData = 1
    case invoice = 2
    case accountData = 3
}

enum _MessageType: Int {
    case normal = 1
    case ecrypted = 2
    case hex = 3
}
