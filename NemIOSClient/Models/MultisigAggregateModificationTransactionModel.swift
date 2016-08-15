//
//  MultisigAggregateModificationTransactionModel.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation
import ObjectMapper

///
class MultisigAggregateModificationTransaction: Transaction {
    
    // MARK: - Model Properties
    
    var type = TransactionType.MultisigAggregateModificationTransaction
    
    // MARK: - Model Lifecycle
    
    required init?(_ map: Map) { }
    
    // MARK: - Model Helper Methods
    
    /// Maps the results from a network request to a transaction object.
    func mapping(map: Map) {
        
        //        balance <- map["account.balance"]
        //        cosignatories <- map["meta.cosignatories"]
    }
}
