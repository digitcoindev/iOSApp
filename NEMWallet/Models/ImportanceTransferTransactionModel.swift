//
//  ImportanceTransferTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import SwiftyJSON

/**
    Represents a importance transfer transaction on the NEM blockchain.
    Visit the [documentation](http://bob.nem.ninja/docs/#importanceTransferTransaction) for more information.
 */
final class ImportanceTransferTransaction: Transaction {
    
    // MARK: - Model Properties
    
    /// The type of the transaction.
    var type = TransactionType.importanceTransferTransaction
    
    /// Additional information about the transaction.
    var metaData: TransactionMetaData?
    
    /// The version of the transaction.
    var version: Int!
    
    /// The number of seconds elapsed since the creation of the nemesis block.
    var timeStamp: Date!
    
    /**
        The mode of the importance transfer transaction. Possible values are:
        1: Activate remote harvesting.
        2: Deactivate remote harvesting.
     */
    var mode: Int!
    
    /// The public key of the receiving account as hexadecimal string.
    var remoteAccount: String!
    
    /// The fee for the transaction.
    var fee: Double!
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    // MARK: - Model Lifecycle
    
    required init?(version: Int, timeStamp: Date, mode: Int, remoteAccount: String, fee: Double, deadline: Int, signer: String) {
        
        self.version = version
        self.timeStamp = timeStamp
        self.mode = mode
        self.remoteAccount = remoteAccount
        self.fee = fee
        self.deadline = deadline
        self.signer = signer
    }
    
    required init?(jsonData: JSON) {
        
        metaData = try? jsonData["meta"].mapObject(TransactionMetaData.self)
        version = jsonData["transaction"]["version"].intValue
        timeStamp = Date(timeIntervalSince1970: jsonData["transaction"]["timeStamp"].doubleValue + Constants.genesisBlockTime)
        mode = jsonData["transaction"]["mode"].intValue
        remoteAccount = jsonData["transaction"]["remoteAccount"].stringValue
        fee = jsonData["transaction"]["fee"].doubleValue / 1000000
        deadline = jsonData["transaction"]["deadline"].intValue
        signature = jsonData["transaction"]["signature"].stringValue
        signer = jsonData["transaction"]["signer"].stringValue
    }
}
