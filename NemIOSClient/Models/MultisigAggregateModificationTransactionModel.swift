//
//  MultisigAggregateModificationTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper
import SwiftyJSON

///
class MultisigAggregateModificationTransaction: Transaction {
    
    // MARK: - Model Properties
    
    var type = TransactionType.MultisigAggregateModificationTransaction
    
    var timeStamp: Int!
    
    /// The fee for the transaction.
    var fee: Int!
    
    /// The deadline of the transaction.
    var deadline: Int!
    
    /// The transaction signature.
    var signature: String!
    
    /// The public key of the account that created the transaction.
    var signer: String!
    
    // MARK: - Model Lifecycle
    
    required init?(_ map: Map) { }
    
    required init?(jsonData: JSON) {
        
//        timeStamp = jsonData["transaction"]["timeStamp"].intValue
    }
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network request to a transaction object.
    func mapping(map: Map) {
        
        //        balance <- map["account.balance"]
        //        cosignatories <- map["meta.cosignatories"]
    }
}
