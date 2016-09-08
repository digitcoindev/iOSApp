//
//  MultisigSignatureTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a multisig signature transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#multisigSignatureTransaction)
    for more information.
 */
public class MultisigSignatureTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    public var type = TransactionType.MultisigSignatureTransaction
    
    /// The version of the transaction.
    public var version: Int!
    
    /// The deadline of the transaction.
    public var timeStamp: Int!
    
    /// The fee for the transaction.
    public var fee: Int!
    
    /// The deadline of the transaction.
    public var deadline: Int!
    
    /// The transaction signature.
    public var signature: String!
    
    /// The public key of the account that created the transaction.
    public var signer: String!
    
    /// The address of the corresponding multisig account.
    var otherAccount: String!
    
    // MARK: - Model Lifecycle
    
    required public init?(jsonData: JSON) {
        
        timeStamp = jsonData["timeStamp"].intValue
        fee = jsonData["fee"].intValue
        deadline = jsonData["deadline"].intValue
        signature = jsonData["signature"].stringValue
        signer = jsonData["signer"].stringValue
        otherAccount = jsonData["otherAccount"].stringValue
    }
}
