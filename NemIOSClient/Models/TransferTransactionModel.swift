//
//  TransferTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

/// The different transfer types for a transfer transaction.
public enum TransferType {
    case Incoming
    case Outgoing
}

/** 
    Represents a transfer transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#transferTransaction)
    for more information.
 */
public class TransferTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    public var type = TransactionType.TransferTransaction
    
    /// Additional information about the transaction.
    public var metaData: TransactionMetaData?
    
    /// The version of the transaction.
    public var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    public var timeStamp: Int!
    
    /// The amount of micro NEM that is transferred from sender to recipient.
    public var amount: Double!
    
    /// The fee for the transaction.
    public var fee: Int!
    
    /// The transfer type of the transaction.
    public var transferType: TransferType?
    
    /// The address of the recipient.
    public var recipient: String!
    
    /// The message of the transaction.
    public var message: Message?
    
    /// The deadline of the transaction.
    public var deadline: Int!
    
    /// The transaction signature.
    public var signature: String!
    
    /// The public key of the account that created the transaction.
    public var signer: String!
    
    // MARK: - Model Lifecycle
    
    required public init?(version: Int, timeStamp: Int, amount: Double, fee: Int, recipient: String, message: Message?, deadline: Int, signer: String) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.amount = amount
        self.fee = fee
        self.recipient = recipient
        self.message = message
        self.deadline = deadline
        self.signer = signer
    }
    
    required public init?(jsonData: JSON) {
        
        metaData = try? jsonData["meta"].mapObject(TransactionMetaData)
        version = jsonData["transaction"]["version"].intValue
        timeStamp = jsonData["transaction"]["timeStamp"].intValue
        amount = jsonData["transaction"]["amount"].doubleValue
        fee = jsonData["transaction"]["fee"].intValue
        recipient = jsonData["transaction"]["recipient"].stringValue
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
        message = {
            var messageObject = try! jsonData["transaction"]["message"].mapObject(Message)
            if messageObject.payload != nil {
                messageObject.signer = signer
                return messageObject
            } else {
                return nil
            }
        }()
    }
}
