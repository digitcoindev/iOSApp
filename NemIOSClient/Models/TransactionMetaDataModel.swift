//
//  TransactionMetaDataModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a transaction meta data object on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#transactionMetaData)
    for more information.
 */
public struct TransactionMetaData: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The id of the transaction.
    public var id: Int?
    
    /// The height of the block in which the transaction was included.
    public var height: Int?
    
    // MARK: - Model Lifecycle
    
    public init?(jsonData: JSON) {
        
        id = jsonData["id"].int
        height = jsonData["height"].int
    }
}
