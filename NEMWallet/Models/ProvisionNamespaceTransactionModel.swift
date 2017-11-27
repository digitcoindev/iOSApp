//
//  ProvisionNamespaceTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a provision namespace transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#provisionNamespaceTransaction) for more information.
 */
final class ProvisionNamespaceTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.provisionNamespaceTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData?
    
    /// The version of the transaction.
    var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date!
    
    /// The new part which is concatenated to the parent with a '.' as separator.
    var newPart: String!
    
    /// The parent namespace. This can be null if the transaction rents a root namespace.
    var parent: String?
    
    /// The fee for renting the namespace.
    var rentalFee: Double!
    
    /// The address of the account to which the rental fee is transferred.
    var rentalFeeSink: String!
    
    /// The fee for the transaction.
    var fee: Double!
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    // MARK: - Model Lifecycle
    
    required init?(version: Int, timeStamp: Date, newPart: String, parent: String?, rentalFee: Double, rentalFeeSink: String, fee: Double, deadline: Int, signer: String) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.newPart = newPart
        self.parent = parent
        self.rentalFee = rentalFee
        self.rentalFeeSink = rentalFeeSink
        self.fee = fee
        self.deadline = deadline
        self.signer = signer
    }
    
    required init?(jsonData: JSON) {
        
        metaData = try? jsonData["meta"].mapObject(TransactionMetaData.self)
        version = jsonData["transaction"]["version"].intValue
        timeStamp = Date(timeIntervalSince1970: jsonData["transaction"]["timeStamp"].doubleValue + Constants.genesisBlockTime)
        newPart = jsonData["transaction"]["newPart"].stringValue
        parent = jsonData["transaction"]["parent"].string
        rentalFee = jsonData["transaction"]["rentalFee"].doubleValue / 1000000
        rentalFeeSink = jsonData["transaction"]["rentalFeeSink"].stringValue
        fee = jsonData["transaction"]["fee"].doubleValue / 1000000
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
    }
}
