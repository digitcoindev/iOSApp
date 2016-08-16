//
//  MessageModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper
import SwiftyJSON

/// All available message types.
enum MessageType: Int {
    case Unencrypted = 1
    case Encrypted = 2
}

/// Represents a transaction message on the NEM blockchain.
struct Message: Mappable, SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The type of the message.
    var type: MessageType!
    
    /// The payload is the actual (possibly encrypted) message data.
    var payload: String!
    
    // MARK: - Model Lifecycle
    
    init?(_ map: Map) { }
    
    init?(jsonData: JSON) {

        type = MessageType(rawValue: jsonData["type"].intValue)
        payload = jsonData["payload"].string
    }
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network request to a transaction message object.
    mutating func mapping(map: Map) {
        
        type <- map["type"]
        payload <- map["payload"]
    }
}
