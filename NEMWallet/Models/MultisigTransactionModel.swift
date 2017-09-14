//
//  MultisigTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a multisig transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#multisigTransaction) for more information.
 */
final class MultisigTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.multisigTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData?
    
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
    
    /// The array of MulsigSignatureTransaction objects.
    var signatures: [MultisigSignatureTransaction]?
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    /// The inner transaction of the multisig transaction.
    var innerTransaction: Transaction!
    
    // MARK: - Model Lifecycle
    
    required init?(version: Int, timeStamp: Date, fee: Double, deadline: Int, signer: String, innerTransaction: Transaction) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.fee = fee
        self.deadline = deadline
        self.signer = signer
        self.innerTransaction = innerTransaction
    }
    
    required init?(jsonData: JSON) {
        
        metaData = try! jsonData["meta"].mapObject(TransactionMetaData.self)
        timeStamp = Date(timeIntervalSince1970: jsonData["transaction"]["timeStamp"].doubleValue + Constants.genesisBlockTime)
        fee = jsonData["transaction"]["fee"].doubleValue / 1000000
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signatures = try! jsonData["transaction"]["signatures"].mapArray(MultisigSignatureTransaction.self)
        signer = jsonData["transaction"]["signer"].stringValue
        
        switch jsonData["transaction"]["otherTrans"]["type"].intValue {
        case TransactionType.transferTransaction.rawValue:
            
            innerTransaction = try! JSON(data: "{\"transaction\":\(jsonData["transaction"]["otherTrans"].rawString()!)}".data(using: String.Encoding.utf8)!).mapObject(TransferTransaction.self)
            (innerTransaction as! TransferTransaction).metaData = metaData
            
        case TransactionType.multisigAggregateModificationTransaction.rawValue:
            
            innerTransaction = try! JSON(data: "{\"transaction\":\(jsonData["transaction"]["otherTrans"].rawString()!)}".data(using: String.Encoding.utf8)!).mapObject(MultisigAggregateModificationTransaction.self)
            (innerTransaction as! MultisigAggregateModificationTransaction).metaData = metaData
            
        default:
            break
        }
    }
}
