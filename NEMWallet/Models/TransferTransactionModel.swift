//
//  TransferTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/** 
    Represents a transfer transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#transferTransaction) for more information.
 */
final class TransferTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The different transfer types for a transfer transaction.
    enum TransferType {
        case incoming
        case outgoing
    }
    
    /// The type of the transaction.
    var type = TransactionType.transferTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData?
    
    /// The version of the transaction.
    var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date!
    
    /// The amount of XEM that is transferred from sender to recipient.
    var amount: Double!
    
    /// The fee for the transaction.
    var fee: Double!
    
    /// The transfer type of the transaction.
    var transferType: TransferType!
    
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
    
    required init?(version: Int, timeStamp: Date, amount: Double, fee: Int, recipient: String, message: Message?, deadline: Int, signer: String) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.amount = amount
        self.fee = Double(fee)
        self.recipient = recipient
        self.message = message
        self.deadline = deadline
        self.signer = signer
    }
    
    required init?(jsonData: JSON) {
        
        metaData = try? jsonData["meta"].mapObject(TransactionMetaData.self)
        version = jsonData["transaction"]["version"].intValue
        timeStamp = Date(timeIntervalSince1970: jsonData["transaction"]["timeStamp"].doubleValue + Constants.genesisBlockTime)
        amount = jsonData["transaction"]["amount"].doubleValue / 1000000
        fee = jsonData["transaction"]["fee"].doubleValue / 1000000
        recipient = jsonData["transaction"]["recipient"].stringValue
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
        message = {
            var messageObject = try! jsonData["transaction"]["message"].mapObject(Message.self)
            if messageObject.payload != nil {
                messageObject.signer = signer
                messageObject.getMessageFromPayload()
                return messageObject
            } else {
                return nil
            }
        }()
        transferType = {
            if signer == AccountManager.sharedInstance.activeAccount?.publicKey {
                return .outgoing
            } else {
                return .incoming
            }
        }()
    }
}
