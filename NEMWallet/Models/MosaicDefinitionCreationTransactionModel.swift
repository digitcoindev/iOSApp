//
//  MosaicDefinitionCreationTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a mosaic definition creation transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#mosaicDefinitionCreationTransaction) for more information.
 */
final class MosaicDefinitionCreationTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.mosaicDefinitionCreationTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData?
    
    /// The version of the transaction.
    var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date!
    
    /// The definition of the mosaic.
    var mosaicDefinition: MosaicDefinition!
    
    /// The fee for the creation of the mosaic.
    var creationFee: Double!
    
    /// The address of the account to which the creation fee is tranferred.
    var creationFeeSink: String!
    
    /// The fee for the transaction.
    var fee: Double!
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    // MARK: - Model Lifecycle
    
    required init?(jsonData: JSON) {
        
        metaData = try? jsonData["meta"].mapObject(TransactionMetaData.self)
        version = jsonData["transaction"]["version"].intValue
        timeStamp = Date(timeIntervalSince1970: jsonData["transaction"]["timeStamp"].doubleValue + Constants.genesisBlockTime)
        mosaicDefinition = try? jsonData["transaction"]["mosaicDefinition"].mapObject(MosaicDefinition.self)
        creationFee = jsonData["transaction"]["creationFee"].doubleValue / 1000000
        creationFeeSink = jsonData["transaction"]["creationFeeSink"].stringValue
        fee = jsonData["transaction"]["fee"].doubleValue / 1000000
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
    }
}
