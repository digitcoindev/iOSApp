//
//  ImportanceTransferTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

///
open class ImportanceTransferTransaction: Transaction {
    
    // MARK: - Model Properties
    
    open var type = TransactionType.importanceTransferTransaction
    
    /// The id of the transaction.
    open var id: Int?
    
    /// The height of the block in which the transaction was included.
    open var height: Int?
    
    /// The version of the transaction.
    open var version: Int!
    
    open var timeStamp: Int!
    
    /// The fee for the transaction.
    open var fee: Int!
    
    /// The deadline of the transaction.
    open var deadline: Int!
    
    /// The transaction signature.
    open var signature: String!
    
    /// The public key of the account that created the transaction.
    open var signer: String!
    
    // MARK: - Model Lifecycle
    
    required public init?(jsonData: JSON) {
        
//        timeStamp = jsonData["transaction"]["timeStamp"].intValue
    }
}
