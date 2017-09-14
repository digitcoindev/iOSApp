//
//  MultisigSignatureTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a multisig signature transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#multisigSignatureTransaction) for more information.
 */
final class MultisigSignatureTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.multisigSignatureTransaction
    
    /// The version of the transaction.
    var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date!
    
    /// The fee for the transaction.
    var fee: Double!
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    /// The length of the hash of the corresponding multisig transaction.
    var hashObjectLength = 36
    
    /// The length of the transaction hash.
    var hashLength = 32
    
    /// The length of the address of the corresponding multisig account.
    var multisigAccountLength = 40
    
    /// The hash of the inner transaction of the corresponding multisig transaction.
    var otherHash: String!
    
    /// The address of the corresponding multisig account.
    var otherAccount: String!
    
    // MARK: - Model Lifecycle
    
    required init?(version: Int, timeStamp: Date, fee: Double, deadline: Int, signer: String, otherHash: String, otherAccount: String) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.fee = fee
        self.deadline = deadline
        self.signer = signer
        self.otherHash = otherHash
        self.otherAccount = otherAccount
    }
    
    required init?(jsonData: JSON) {
        
        timeStamp = Date(timeIntervalSince1970: jsonData["timeStamp"].doubleValue + Constants.genesisBlockTime)
        fee = jsonData["fee"].doubleValue / 1000000
        deadline = jsonData["deadline"].intValue
        signature = jsonData["signature"].stringValue
        signer = jsonData["signer"].stringValue
        otherHash = jsonData["otherHash"].stringValue
        otherAccount = jsonData["otherAccount"].stringValue
    }
}
