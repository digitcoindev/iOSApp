//
//  TransferTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper
import SwiftyJSON

/** 
    Represents a transfer transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#transferTransaction)
    for more information.
 */
class TransferTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.TransferTransaction
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Int!
    
    /// The amount of micro NEM that is transferred from sender to recipient.
    var amount: Int!
    
    /// The fee for the transaction.
    var fee: Int!
    
    /// The address of the recipient.
    var recipient: String!
    
    /// The message of the transaction.
    var message: Message?
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    // MARK: - Model Lifecycle
    
    required init?(_ map: Map) { }
    
    required init?(jsonData: JSON) {
        
        timeStamp = jsonData["transaction"]["timeStamp"].intValue
        amount = jsonData["transaction"]["amount"].intValue
        fee = jsonData["transaction"]["fee"].intValue
        recipient = jsonData["transaction"]["recipient"].stringValue
        message = {
            let messageObject = try! jsonData["transaction"]["message"].mapObject(Message)
            if messageObject.type != nil && messageObject.payload != nil { return messageObject } else { return nil }
        }()
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
    }
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network request to a transaction object.
    func mapping(map: Map) {
        
        timeStamp <- map["transaction.timeStamp"]
        amount <- map["transaction.amount"]
        fee <- map["transaction.fee"]
        recipient <- map["transaction.recipient"]
        message <- map["transaction.message"]
        deadline <- map["transaction.deadline"]
        signature <- map["transaction.signature"]
        signer <- map["transaction.signer"]
    }
}
