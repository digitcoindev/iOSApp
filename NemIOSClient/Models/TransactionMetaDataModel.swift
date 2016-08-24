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
struct TransactionMetaData: SwiftyJSONMappable {
    
    // MARK: - Model Properties
    
    /// The id of the transaction.
    var id: Int?
    
    /// The height of the block in which the transaction was included.
    var height: Int?
    
    // MARK: - Model Lifecycle
    
    init?(jsonData: JSON) {
        
        id = jsonData["id"].int
        height = jsonData["height"].int
    }
}
