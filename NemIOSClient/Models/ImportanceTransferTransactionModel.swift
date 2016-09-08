//
//  ImportanceTransferTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import SwiftyJSON

///
public class ImportanceTransferTransaction: Transaction {
    
    // MARK: - Model Properties
    
    public var type = TransactionType.ImportanceTransferTransaction
    
    /// The id of the transaction.
    public var id: Int?
    
    /// The height of the block in which the transaction was included.
    public var height: Int?
    
    /// The version of the transaction.
    public var version: Int!
    
    public var timeStamp: Int!
    
    /// The fee for the transaction.
    public var fee: Int!
    
    /// The deadline of the transaction.
    public var deadline: Int!
    
    /// The transaction signature.
    public var signature: String!
    
    /// The public key of the account that created the transaction.
    public var signer: String!
    
    // MARK: - Model Lifecycle
    
    required public init?(jsonData: JSON) {
        
//        timeStamp = jsonData["transaction"]["timeStamp"].intValue
    }
}
