//
//  MultisigTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a multisig transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#multisigTransaction)
    for more information.
 */
class MultisigTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.MultisigTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Int!
    
    /// The fee for the transaction.
    var fee: Int!
    
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
    
    required init?(jsonData: JSON) {
        
        metaData = try! jsonData["meta"].mapObject(TransactionMetaData)
        timeStamp = jsonData["transaction"]["timeStamp"].intValue
        fee = jsonData["transaction"]["fee"].intValue
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signatures = try! jsonData["transaction"]["signatures"].mapArray(MultisigSignatureTransaction)
        signer = jsonData["transaction"]["signer"].stringValue
        
        switch jsonData["transaction"]["otherTrans"]["type"].intValue {
        case TransactionType.TransferTransaction.rawValue:
            
            innerTransaction = try! JSON(data: "{\"transaction\":\(jsonData["transaction"]["otherTrans"])}".dataUsingEncoding(NSUTF8StringEncoding)!).mapObject(TransferTransaction) 
            (innerTransaction as! TransferTransaction).metaData = metaData
            
        default:
            break
        }
    }
}
